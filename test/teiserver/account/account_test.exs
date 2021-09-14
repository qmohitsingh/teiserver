defmodule Teiserver.AccountTest do
  use Central.DataCase

  alias Teiserver.Account
  alias Central.Account.AccountTestLib

  describe "users" do
    alias Central.Account.User

    @valid_attrs %{
      colour: "some colour",
      icon: "far fa-home",
      name: "some name",
      permissions: [],
      email: "some email",
      password: "some password"
    }
    @update_attrs %{
      colour: "some updated colour",
      icon: "fas fa-wrench",
      permissions: [],
      name: "some updated name",
      email: "some updated email",
      password: "some updated password"
    }
    @invalid_attrs %{
      colour: nil,
      icon: nil,
      name: nil,
      permissions: nil,
      email: nil,
      password: nil
    }

    test "list_users/0 returns users" do
      assert Account.list_users() != []
    end

    test "list_users with extra filters" do
      # We don't care about the actual results at this point, just that the filters are called
      Account.list_users(search: [
        exact_name: "",
        data_equal: {"field", "value"},
        data_greater_than: {"field", "123"},
        data_less_than: {"field", "123"},
        ip: "123.456.789.123",
        mute_or_ban: nil,

        # Tests the fallback to Central.UserQueries
        name_like: ""
      ],
      joins: [:user_stat])

      # Flag filters as true
      Account.list_users(search: [
        bot: "Robot",
        moderator: "Moderator",
        verified: "Verified",
        tester: "Tester",
        streamer: "Streamer",
        donor: "Donor",
        contributor: "Contributor",
        developer: "Developer",
      ])

      # Flag filters as false
      Account.list_users(search: [
        bot: "Person",
        moderator: "User",
        verified: "Unverified",
        tester: "Normal",
        streamer: "Normal",
        donor: "Normal",
        contributor: "Normal",
        developer: "Normal",
      ])

      # Order by
      Account.list_users(order_by: {:data, "field", :asc})
      Account.list_users(order_by: {:data, "field", :desc})

      # Fallback
      Account.list_users(order_by: {:data, "field", :desc})
    end

    test "get_user!/1 returns the user with given id" do
      user = AccountTestLib.user_fixture()
      assert Account.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Account.create_user(@valid_attrs)
      assert user.colour == "some colour"
      assert user.icon == "far fa-home"
      assert user.name == "some name"
      assert user.permissions == []
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = AccountTestLib.user_fixture()
      assert {:ok, %User{} = user} = Account.update_user(user, @update_attrs)
      assert user.colour == "some updated colour"
      assert user.icon == "fas fa-wrench"
      assert user.name == "some updated name"
      assert user.permissions == []
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = AccountTestLib.user_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_user(user, @invalid_attrs)
      assert user == Account.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = AccountTestLib.user_fixture()
      assert {:ok, %User{}} = Account.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Account.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = AccountTestLib.user_fixture()
      assert %Ecto.Changeset{} = Account.change_user(user)
    end
  end
end