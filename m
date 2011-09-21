Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab1IUEQo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 00:16:44 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Please support NSF squashing multiple groups
Date: Tue, 20 Sep 2011 21:16:26 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480225@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <201109210009.p8L09pgs026367@bari.maths.usyd.edu.au>
References: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B48011F@SACMVEXC2-PRD.hq.netapp.com> <201109210009.p8L09pgs026367@bari.maths.usyd.edu.au>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: <paul.szabo@sydney.edu.au>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: paul.szabo@sydney.edu.au [mailto:paul.szabo@sydney.edu.au]
> Sent: Tuesday, September 20, 2011 8:10 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: Please support NSF squashing multiple groups
> 
> > ... It is too easy to fake a uid or a gid when you use a protocol
that
> > exposes them in clear on the network ...
> 
> Trivial to find out what they are, may not be so easy to inject them.

If you are inside the network? All you need is a client and sufficient
privileges to open a privileged port. You get bonus points if you can
also compromise a router/switch...
 
> > ... I don't at all understand your threat model. You appear to be
> > worried about a threat where a user can somehow usurp gids but not
> > uids on the client.
> 
> I am worried about an attacker being able to "do anything" on the
client
> (having "cracked root" on it).
>
> In terms of usurping UIDs, he is pretty much defeated: the only
privileged
> UID is root, rendered harmless by root_squash. (Beware that other UIDs
e.g.
> bin or sys may be dangerous on some systems:
> root_squash as currently implemented is incomplete, insecure.)

Ermm... If you can spoof any user (except root), then surely there are
several alternatives open to you. If home directories are on NFS, then I
can imagine installing ssh keys to enable me to log on to any client in
the system, or setting up spoofed .profile files.

Alternatively, poisoning their namespace with a well placed symlink, or 

> There is currently no such protection for usurping GIDs, and some
(e.g. staff
> for Debian, or disk shadow etc) are privileged and root-equivalent. We
need
> protection, similar to root_squash.

Root squashing will automatically also squash gid==0 (whether or not the
uid == 0).

The problem you are describing is different: you have a _list_ of
privileged gids that you want to squash for some reason.  I could
probably find an equivalent list of privileged uids on most systems that
you don't ever want the client to spoof (e.g. 'bin', 'daemon',
'dbus',...).
There are 2 solutions to that problem: either go the route of the
rpc.ugidd daemon, which does general mapping from one set of uid/gids to
another. Alternatively, don't expose anything which is protected by a
privileged uid or gid...

Cheers
    Trond
