Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:37020 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933599Ab2AJAtD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 19:49:03 -0500
From: Wolfgang Walter <wolfgang.walter@stwm.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes and cleanups
Date: Tue, 10 Jan 2012 01:49:00 +0100
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <1326142671.9041.1.camel@lade.trondhjem.org> <A4C37DBDA23D504B9F8F6ED1AD1F4F3245A40D11@SACMVEXC2-PRD.hq.netapp.com> <1326149428.10779.10.camel@lade.trondhjem.org>
In-Reply-To: <1326149428.10779.10.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201201100149.00716.wolfgang.walter@stwm.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 09 January 2012, Trond Myklebust wrote:
> On Mon, 2012-01-09 at 14:28 -0800, Myklebust, Trond wrote: 
> > > -----Original Message-----
> > Please read the changelog and documentation:
> > 
> > If your server doesn’t support numeric uids/gids, then you will see _no_ 
> > change in behaviour.

Hmm, what does that mean exactly? Does a linux nfs4-server support numeric 
uids/gids? If yes, by default or do I need do set an option?

> > 
> > If your server does support numeric uids/gids, and has the same mapping 
between numeric uids/gids and username/groupname as your clients, then you 
will see _no_ change in behaviour.
> > 
> > If your server does support numeric uids/gids, but the mapping between 
> > numeric uids/gids and username/groupname differs between server and client 
> > (e.g.. uid=20 maps to different users on the client and server) then you 
> > already had a problem in that creating the file using NFSv4 would result 
> > in you seeing the wrong owner and/or group. If this case, and this case 
> > only, the change to nfs4_disable_idmapper will result in you now seeing 
> > the correct owner/group for these files (just as if you were using NFSv3).

The only thing I can say is that in the moment client and server are using 
rpc.idmapd and it works perfectly well.

> > 
> > IOW: the only people who will want to use the old setting are those with 
> > broken servers that return incorrect errors when confronted with a numeric 
> > uid/gid. We have found no evidence that any such servers exist during the 
> > last full year of testing.
> 
> Actually, let me amend that last statement.
> 
> The only broken server we found was the Linux server, which was
> returning NFS4ERR_BADNAME in a situation where the protocol specified
> that it should be returning NFS4ERR_BADOWNER. This is why we have the
> little comment "The following works around a Linux server bug!" in the
> client code.
> Commit f6af99ec1b261e21219d5eba99e3af48fc6c32d4 (nfsd4: name->id mapping
> should fail with BADOWNER not BADNAME) fixed that server bug exactly one
> year ago, and the fix was subsequently pushed to stable@kernel.org...
> 
> IOW: unless you find something earth-shattering when you enable the
> option in your existing clients (the option has existed since 2.6.39),
> I'd prefer to change the default as soon as possible in order to fix the
> existing brokenness for those people running NFSv4 without the benefit
> of an ldap/nis/yp server to ensure a homogeneous uid/gid name space...

I always thought that the idmapper with its translation were exactly for that 
case. If I have a homogenous uid/gid name space why would I want to use names 
and translate anyway?


Regards,
-- 
Wolfgang Walter
Studentenwerk München
Anstalt des öffentlichen Rechts
