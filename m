From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: regression, bisected: getcwd() ENOENT on NFS4...
Date: Sun, 25 Oct 2009 23:31:34 +0000
Message-ID: <6278d2220910251631j40caec00lf2dee6159947d983@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:62336 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbZJYXbb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Oct 2009 19:31:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since 2.6.30-rc, I've been experiencing various issues relating to
getcwd() returning ENOENT on NFS4 clients. I used an over-complicated
but reliable reproducer [1] (on Karmic RC against a 2.6.32-rc5 NFS4
server) to bisect [2].

The impact of this regression is moderate (side-effects range from
benign to failure), so we should get a fix into 2.6.32 if at all
possible and strongly consider a 2.6.31 stable update.

Thanks,
  Daniel

--- [1]

$ apt-get source apt
$ cd apt-*
$ ./configure && make
[snip]
sh: getcwd() failed: No such file or directory

--- [2]

a65318bf3afc93ce49227e849d213799b072c5fd is first bad commit
commit a65318bf3afc93ce49227e849d213799b072c5fd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:28 2009 -0400

    NFSv4: Simplify some cache consistency post-op GETATTRs

    Certain asynchronous operations such as write() do not expect
    (or care) that other metadata such as the file owner, mode, acls, ...
    change. All they want to do is update and/or check the change attribute,
    ctime, and mtime.
    By skipping the file owner and group update, we also avoid having to do a
    potential idmapper upcall for these asynchronous RPC calls.

    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

:040000 040000 0c89c426fff3ad249757e3f77327ea79902df64b
6c96fe34f548df08cd11771fbcc839b44a5607e1 M	fs
:040000 040000 6ce4d50124b9dd214c54a42bd922a2b9da10aca2
16f551da881e2d2faeb786e5c47cfe0a21f42ade M	include
-- 
Daniel J Blueman
