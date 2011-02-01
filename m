Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36318 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab1BADYx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jan 2011 22:24:53 -0500
Received: by wwi17 with SMTP id 17so4304374wwi.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Jan 2011 19:24:52 -0800 (PST)
In-Reply-To: <AANLkTinD01zA=DTXEDG5pXVYcrEGsWOyXcMta0rzvB6n@mail.gmail.com>
References: <AANLkTinD01zA=DTXEDG5pXVYcrEGsWOyXcMta0rzvB6n@mail.gmail.com>
From: camden lindsay <camden.lindsay@gmail.com>
Date: Mon, 31 Jan 2011 19:24:30 -0800
Message-ID: <AANLkTimA-sCz8LQLu1weh-qQOm30jHYyO3qtxmPDPX98@mail.gmail.com>
Subject: clients cannot reconnect to mounted nfs shares after server restart
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Having an issue i believe is an NFS bug, but would like someone to
verify as well as... point me the correct direction to submit a bug as
needed if it indeed is.
Situation:
NFS server running
Client connected with mounted share
NFS server is shut down -- (halt or /etc/init.d/nfs stop)
NFS server is turned on (booted or /etc/init.d/nfs start)

Outcome:
NFS client that was connected does not reconnect to that share automatically
NFS client that was connected cannot reconnect via umount then mount again
No other nfs client can connect to that share, before or after origial
NFS clients attempts to connect/reconnect
NFS clients CAN connect to a different share.
Details/logs:
Server shows that client is authenticating:
Feb  1 03:01:47 BigBox mountd[6557]: authenticated mount request from
192.168.11.49:674 for /mnt/store/public (/mnt/store/public)
Feb  1 03:01:48 BigBox mountd[6557]: authenticated mount request from
192.168.11.49:763 for /mnt/store/public (/mnt/store/public)
Feb  1 03:01:50 BigBox mountd[6557]: authenticated mount request from
192.168.11.49:932 for /mnt/store/public (/mnt/store/public)
Feb  1 03:01:54 BigBox mountd[6557]: authenticated mount request from
192.168.11.49:942 for /mnt/store/public (/mnt/store/public)

Client shows retransmission:
dylan@shobuntu:~$ sudo mount -v -t nfs bigbox:/mnt/store/public Public/
mount.nfs: timeout set for Mon Jan 31 19:09:32 2011
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'

Server Version:
net-fs/nfs-utils
      Latest version available: 1.1.4-r1
      Latest version installed: 1.1.4-r1
      Size of files: 574 kB
      Homepage:      http://linux-nfs.org/
      Description:   NFS client and server daemons
      License:       GPL-2
(server is on Gentoo, client on Ubuntu)
Thanks!
Camden
