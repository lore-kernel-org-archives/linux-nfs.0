From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Client cache updates missing? (2.6.31.5)
Date: Sun, 29 Nov 2009 09:24:18 +0100
Message-ID: <4B122FB2.7040505@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:52073 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbZK2IYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Nov 2009 03:24:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id BE0001DFD05
	for <linux-nfs@vger.kernel.org>; Sun, 29 Nov 2009 09:24:30 +0100 (CET)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6WD4qUVJLowY for <linux-nfs@vger.kernel.org>;
	Sun, 29 Nov 2009 09:24:22 +0100 (CET)
Received: from [90.184.13.137] (unknown [90.184.13.137])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: jesper-Q2TZfHgGEy4@public.gmane.org)
	by shrek.krogh.cc (Postfix) with ESMTPSA id 115D41DFD03
	for <linux-nfs@vger.kernel.org>; Sun, 29 Nov 2009 09:24:22 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I'm seeing some random odd behaviour on my NFS clients. It is
not directly reproducible, but I have had users telling me about, but
until you hit stuff like this yourself .. you almost dont believe it.

jk@bach:~$ ssh nfsserver ls -ltrah | grep blast-2.out
-rw-rw-r--   1 jk jk 552K 2009-11-29 09:10 blast-2.out
jk@bach:~$ ls -tlrha  | grep blast-2.out
jk@bach:~$ date
Sun Nov 29 09:17:14 CET 2009
jk@bach:~$ stat blast-2.out
  File: `blast-2.out'
  Size: 564283    	Blocks: 1112       IO Block: 1048576 regular file
Device: 18h/24d	Inode: 139405089   Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/      jk)   Gid: ( 1000/      jk)
Access: 2009-11-29 09:07:34.000000000 +0100
Modify: 2009-11-29 09:10:27.000000000 +0100
Change: 2009-11-29 09:10:27.0000

So.. the file has been present for 7 minutes on the NFS-server (and any
client doing a fresh mount) but the client I'm sitting on is not having
the file in the directory listing, but if I explicitly ask for it.. its
there.

Wether or not it has anything to do. The file has been written to the
NFS-server from another NFS-client. The server is running 2.6.31.5 and
the client that above was run on is 2.6.24-24 (Ubuntu Jaunty), the
client that wrote the file was running 2.6.29.1.

Jesper
-- 
Jesper
