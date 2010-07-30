Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51127 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932278Ab0G3Sss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 14:48:48 -0400
Date: Fri, 30 Jul 2010 14:47:38 -0400
To: =?utf-8?B?Si5BLiBNYWdhbGzDs24=?= <jamagallon@ono.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: Questions and problems with NFS4
Message-ID: <20100730184738.GF21729@fieldses.org>
References: <20100728004611.00c46b13@werewolf.home>
 <4C507208.6030309@oracle.com>
 <20100730021837.65549fa7@werewolf.home>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20100730021837.65549fa7@werewolf.home>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 30, 2010 at 02:18:37AM +0200, J.A. Magallón wrote:
> First of all, plz correct me if this is in some kind of wiki, web page or
> the like, but I have not been able to find it. All this things should be
> on a document somewhere, perhaps even in the kernel itself...

Agreed.

> These are the things I have found out (thanks to your answers...).
> I'm a long time unix admin, not new to NFS, but all this things were not
> obvious to me, so perhaps they deserve to be in a document, something like
> "NFS 3 to 4 migration for dummy admins":
> 
> - Everything just works if you mount shares as nfs4. Even, if you have a
>   bunch of linux boxen with recent kernel/nfs-utils, probably you are
>   already doing nfs4... modern mount tries nfs4 first.
> 
> - Using nfsroot with fsid=0 is not mandatory, nor bind-mounting everything
>   under some /export (like many documents say), that only forces you to

We should update that documentation.

>   use the old way of specifying paths in the server (absolute, not
>   relative to /export).
> 
> - Even if you use nfsroot(fsid=0), and you mount it on the client
>   at /somepoint, you are not forced to mount everything else under
>   /somepoint (plz, correct me if I'm wrong).
> 
> - You can strip your server for NFS4, but not too much... Old daemons
>   are still needed locally. For example, you can get rid of NFS2 and
>   UDP for nfsd (-N 2 -U, -any os still uses NFS2??-), and old
>   mount protocols (-N 1 -N 2 for mountd)...
> 
> - ... but they can be firewalled, use is just local
> 
> - portmap/rpcbind is not needed, but still used because nfsd is not
>   yet proper clean for only-nfs4-behavior.
> 
> There are also some things I have not been able to discover, like
> using the interesting things of NFS4:
> 
> - How do you activate delegations ? Is this an automatic thing, or
>   do I have to add any option somewhere ?

It's automatic.  You can turn them off on the server side with
/proc/sys/fs/leases-enable.  They'll be turned off automatically if the
server can't open a tcp connection back to the client (for example, if
the client is behind a NAT).

> - How do you use cache ? Many docs talk about fsc option, but man
>   does not mention it (nfs-utils 1.2.2).
>   I have tried to use cachefiles module, and cachefilesd, but
>   when I try to run it, I get:

I haven't used that.  I don't believe there's anything NFSv4-specific
about it.

--b.
