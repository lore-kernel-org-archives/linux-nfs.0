From: "Thomas Garner" <thomas536@gmail.com>
Subject: more nfsv4 lockups w/ nexenta
Date: Thu, 11 Dec 2008 12:40:25 -0500
Message-ID: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:63371 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756592AbYLKRqd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 12:46:33 -0500
Received: by fk-out-0910.google.com with SMTP id 18so635815fkq.5
        for <linux-nfs@vger.kernel.org>; Thu, 11 Dec 2008 09:46:31 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a Debian client running 2.6.27.5 connecting over nfsv4 to a
Nexenta nfs server running b85 (and even with b103) that is
experiencing nfs lockups.  The symptoms are basically that nfs stops
working (usually first noticed as Firefox locking up, but trying to
log in as a user w/ an nfs mounted home dir hangs as well, as does
trying to list said nfs mounted home directory).  Trying a `umount -f`
doesn't usually resolve the issue.  Unfortunately there are no logs
indicating what the issue is, so I've done some preliminary dumps.
Here is the relevant portion of the process list:

 3295 ?        S<    24:55  \_ [rpciod/0]
 3296 ?        S<    46:14  \_ [rpciod/1]
 3297 ?        S<    55:17  \_ [rpciod/2]
 3298 ?        S<    19:01  \_ [rpciod/3]
 3315 ?        R<   185:15  \_ [nfsiod]
 4464 ?        D<     0:00  \_ [nfsv4-svc]
25203 ?        S      0:00  \_ [pdflush]
26618 ?        S      0:00  \_ [pdflush]
27343 ?        R<   252:35  \_ [192.168.0.10-re]
27344 ?        D      0:00  \_ [nfsv4-delegretu]

I've also put up a /var/log/messages with `rpcdebug -m rpc -s all` and
`rpcdebug -m nfs -s all` turned on:

http://s120158928.onlinehome.us/messages.2.gz

And a `tcpdump -s 0 -w nfs_dump_argento5 -x -i eth0`:

http://s120158928.onlinehome.us/nfs_dump_argento5

Looking forward to debugging and resolving,
Thomas
