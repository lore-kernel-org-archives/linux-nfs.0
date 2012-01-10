Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7227 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932317Ab2AJBxT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 20:53:19 -0500
Message-ID: <1326160381.13527.4.camel@lade.trondhjem.org>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes and cleanups
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Mon, 09 Jan 2012 20:53:01 -0500
In-Reply-To: <201201100149.00716.wolfgang.walter@stwm.de>
References: <1326142671.9041.1.camel@lade.trondhjem.org>
	 <A4C37DBDA23D504B9F8F6ED1AD1F4F3245A40D11@SACMVEXC2-PRD.hq.netapp.com>
	 <1326149428.10779.10.camel@lade.trondhjem.org>
	 <201201100149.00716.wolfgang.walter@stwm.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-01-10 at 01:49 +0100, Wolfgang Walter wrote: 
> On Monday 09 January 2012, Trond Myklebust wrote:
> > On Mon, 2012-01-09 at 14:28 -0800, Myklebust, Trond wrote: 
> > > > -----Original Message-----
> > > Please read the changelog and documentation:
> > > 
> > > If your server doesn’t support numeric uids/gids, then you will see _no_ 
> > > change in behaviour.
> 
> Hmm, what does that mean exactly? Does a linux nfs4-server support numeric 
> uids/gids? If yes, by default or do I need do set an option?


The patch requires no changes to a configuration that is already
working. That's the whole point I've been trying to get across.

> > > 
> > > If your server does support numeric uids/gids, and has the same mapping 
> between numeric uids/gids and username/groupname as your clients, then you 
> will see _no_ change in behaviour.
> > > 
> > > If your server does support numeric uids/gids, but the mapping between 
> > > numeric uids/gids and username/groupname differs between server and client 
> > > (e.g.. uid=20 maps to different users on the client and server) then you 
> > > already had a problem in that creating the file using NFSv4 would result 
> > > in you seeing the wrong owner and/or group. If this case, and this case 
> > > only, the change to nfs4_disable_idmapper will result in you now seeing 
> > > the correct owner/group for these files (just as if you were using NFSv3).
> 
> The only thing I can say is that in the moment client and server are using 
> rpc.idmapd and it works perfectly well.

Then why are you complaining?

"This patch does nothing for me is NOT a reason to stop others from
benefiting from it"

> > > 
> > > IOW: the only people who will want to use the old setting are those with 
> > > broken servers that return incorrect errors when confronted with a numeric 
> > > uid/gid. We have found no evidence that any such servers exist during the 
> > > last full year of testing.
> > 
> > Actually, let me amend that last statement.
> > 
> > The only broken server we found was the Linux server, which was
> > returning NFS4ERR_BADNAME in a situation where the protocol specified
> > that it should be returning NFS4ERR_BADOWNER. This is why we have the
> > little comment "The following works around a Linux server bug!" in the
> > client code.
> > Commit f6af99ec1b261e21219d5eba99e3af48fc6c32d4 (nfsd4: name->id mapping
> > should fail with BADOWNER not BADNAME) fixed that server bug exactly one
> > year ago, and the fix was subsequently pushed to stable@kernel.org...
> > 
> > IOW: unless you find something earth-shattering when you enable the
> > option in your existing clients (the option has existed since 2.6.39),
> > I'd prefer to change the default as soon as possible in order to fix the
> > existing brokenness for those people running NFSv4 without the benefit
> > of an ldap/nis/yp server to ensure a homogeneous uid/gid name space...
> 
> I always thought that the idmapper with its translation were exactly for that 
> case. If I have a homogenous uid/gid name space why would I want to use names 
> and translate anyway?

For RPCSEC_GSS authentication. That's the only case that the original
RFC3530 cared about. The problems arise when people use AUTH_SYS, and
this protocol change+patch is the solution.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

