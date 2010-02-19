Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:51773 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631Ab0BSTTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Feb 2010 14:19:20 -0500
Subject: Re: NFSv4
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J.A." =?ISO-8859-1?Q?Magall=F3n?= <jamagallon@ono.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
In-Reply-To: <20100219012322.3d323794@werewolf.home>
References: <20100219012322.3d323794@werewolf.home>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Feb 2010 11:19:14 -0800
Message-ID: <1266607154.3526.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-02-19 at 01:23 +0100, J.A. Magallón wrote: 
> Hi all...
> 
> First of all, kudos for new nfs-utils. Now, nfs4 works automagically and
> like a charm.
> 
> And now the hard part, some questions:
> 
> - I have read that nfs4 includes in the server the locking protocol, no
>   need for separate lockd. But in my servers, it seems it is still running:
> 
> root      2198     2  0 Feb18 ?        00:00:00 [nfsiod]
> root     23501     2  0 01:01 ?        00:00:00 [nfsd4]
> root     23502     2  0 01:01 ?        00:00:00 [nfsd]
> root     23503     2  0 01:01 ?        00:00:00 [nfsd]
> root     23504     2  0 01:01 ?        00:00:00 [nfsd]
> root     23505     2  0 01:01 ?        00:00:00 [nfsd]
> root     23506     2  0 01:01 ?        00:00:00 [nfsd]
> root     23507     2  0 01:01 ?        00:00:00 [nfsd]
> root     23508     2  0 01:01 ?        00:00:00 [nfsd]
> root     23509     2  0 01:01 ?        00:00:00 [nfsd]
> root     23500     2  0 01:01 ?        00:00:00 [lockd]
> 
>   Is there any problem with it ? I suppose (correct me if I'm wrong)
>   that this kernel lockd will only serve for v2 or v3 mounts,
>   that locking for client nfs4 mounts will go through nfsd4.
>   Is that right ?

No. The client NFSv4 traffic goes through the ordinary 'nfsd' daemons.
There is no special locking manager for NFSv4, since POSIX locks are
part of the ordinary protocol.

I don't think that the NFS server will switch off lockd even if you do
specify that you only want to serve NFSv4.

> - Why is there only 1 instance of v4 daemon ?

The 'nfsd4' thread above is actually a workqueue that is used for
garbage-cleaning expired NFSv4 state. It isn't a server thread.

> - Is there any page describing the advantages of v4 ? I will have to
>   convince the department admin to activate v4 in his solaris boxen...;)

One place to start is the NFSv4 design considerations. See
          http://tools.ietf.org/html/rfc2624

Cheers
  Trond

