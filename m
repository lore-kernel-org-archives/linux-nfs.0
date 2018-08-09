Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55415 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726756AbeHIUdc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2018 16:33:32 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
        by mailout.nyi.internal (Postfix) with ESMTP id 33FAF20DD4
        for <linux-nfs@vger.kernel.org>; Thu,  9 Aug 2018 14:07:33 -0400 (EDT)
Message-Id: <1533838052.2201783.1469033928.4B670F71@webmail.messagingengine.com>
From: mrsvd1v4rgo1@airpost.net
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Date: Thu, 09 Aug 2018 11:07:32 -0700
Subject: Help with user ID mapping?
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I'm trying to get a NFS4 client & server id mapping working right.

My client mounts to a couple of NFS4 servers.

I want to get it setup so that for just ONE of them, files added to or modified on the server BY my local client, logged in EITHER as my user or root, get written with a specific user/group ==  "nobody:users"

I'm pretty sure that all the magic is done with idmapd config.

This is what I put together after reading the docs and a bunch of posts online.  Obviously I'm still doing something wrong.

On my Desktop I have an autofs mount

	cat /etc/auto.nfs4 | grep TEST
		TEST     -fstype=nfs,vers=4,_netdev,rw,proto=tcp,async,soft,cto,user,sec=sys,exec,nosuid,nodev,fsc,forcedirectio,rsize=32768,wsize=32768  nas.my.lan:/data/media1

I've got local users of

	id nobody
		uid=65534(nobody) gid=65533(nobody) groups=65534(nogroup),65533(nobody)

	id testuser
		uid=1000(testuser) gid=100(users) groups=6(disk),0(root),494(serviio),33(video),10(wheel),100(users)

	id root
		uid=0(root) gid=0(root) groups=6(disk),494(serviio),100(users),0(root)

And a mapping config of

	cat /etc/idmapd.conf
		[General]

		Verbosity = 0
		Pipefs-Directory = /var/lib/nfs/rpc_pipefs
		Domain = localdomain

		[Mapping]

		Nobody-User = nobody
		Nobody-Group = nobody


When I create files on the server from my local client as either a normal user or root

	cd /mnt/NFS4/TEST
	whoami
		testuser
	touch test1.txt
	su
	whoami
		root
	touch test2.txt

Locally, it looks like I end up with "nobody:nobody"

	ls -al test*
		-rw-r--r-- 1 nobody nobody 0 Aug  9 10:31 test1.txt
		-rw-r--r-- 1 nobody nobody 0 Aug  9 10:31 test2.txt


On the Server, the export is

	grep vol /etc/exports
		/data/media1     10.1.1.0/24(rw,sync,no_wdelay,insecure,no_root_squash,insecure_locks,sec=sys,anonuid=1025,anongid=100)

Users are

	id nobody
		uid=99(nobody) gid=99(nobody) groups=99(nobody)

	id testuser
		uid=1026(testuser) gid=100(users) groups=100(users),101(administrators),1023(http)

	id root
		uid=0(root) gid=0(root) groups=0(root),2(daemon),19(log)

	id 1025
		uid=1025(guest) gid=100(users) groups=100(users)

and the mapping file is

	cat /etc/idmapd.conf
		[General]
		Verbosity = 0
		Pipefs-Directory = /var/lib/nfs/rpc_pipefs
		Domain = my.lan

		[Mapping]
		Nobody-User  = nobody
		Nobody-Group = nobody

		[Translation]
		Method = nsswitch

		[Static]

But still

	cd /data/media1
	ls -al test*
		-rw-r--r-- 1 1000 users 0 Aug  9 10:31 test1.txt
		-rw-r--r-- 1 root root  0 Aug  9 10:31 test2.txt

I'll be the 1st to admit that I'm having a heckuva time understanding this mapping biz! :-/

What do I need to change in my config so i end up with

	cd /data/media1
	ls -al test*
		-rw-r--r-- 1 nobody users 0 Aug  9 10:31 test1.txt
		-rw-r--r-- 1 nobody users  0 Aug  9 10:31 test2.txt

on this and only this server?  I.e., so I can use THIS mapping for THIS server, and OTHER mappings for OTHER servers.

Thanks for any help!

Arnie
