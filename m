From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: more nfsv4 lockups w/ nexenta
Date: Thu, 11 Dec 2008 13:02:08 -0500
Message-ID: <1229018528.6463.23.camel@heimdal.trondhjem.org>
References: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Thomas Garner <thomas536@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47429 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755416AbYLKSCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Dec 2008 13:02:13 -0500
In-Reply-To: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-12-11 at 12:40 -0500, Thomas Garner wrote:
> I have a Debian client running 2.6.27.5 connecting over nfsv4 to a
> Nexenta nfs server running b85 (and even with b103) that is
> experiencing nfs lockups.  The symptoms are basically that nfs stops
> working (usually first noticed as Firefox locking up, but trying to
> log in as a user w/ an nfs mounted home dir hangs as well, as does
> trying to list said nfs mounted home directory).  Trying a `umount -f`
> doesn't usually resolve the issue.  Unfortunately there are no logs
> indicating what the issue is, so I've done some preliminary dumps.
> Here is the relevant portion of the process list:
> 
>  3295 ?        S<    24:55  \_ [rpciod/0]
>  3296 ?        S<    46:14  \_ [rpciod/1]
>  3297 ?        S<    55:17  \_ [rpciod/2]
>  3298 ?        S<    19:01  \_ [rpciod/3]
>  3315 ?        R<   185:15  \_ [nfsiod]
>  4464 ?        D<     0:00  \_ [nfsv4-svc]
> 25203 ?        S      0:00  \_ [pdflush]
> 26618 ?        S      0:00  \_ [pdflush]
> 27343 ?        R<   252:35  \_ [192.168.0.10-re]
> 27344 ?        D      0:00  \_ [nfsv4-delegretu]
> 
> I've also put up a /var/log/messages with `rpcdebug -m rpc -s all` and
> `rpcdebug -m nfs -s all` turned on:
> 
> http://s120158928.onlinehome.us/messages.2.gz
> 
> And a `tcpdump -s 0 -w nfs_dump_argento5 -x -i eth0`:

>From the logs, it looks like it is recovery related. Did the server
reboot just before the hang?

Cheers
  Trond

