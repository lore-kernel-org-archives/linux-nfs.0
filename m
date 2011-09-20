Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25810 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab1ITXiz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 19:38:55 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Please support NSF squashing multiple groups
Date: Tue, 20 Sep 2011 16:38:53 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B48011F@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <201109202329.p8KNTGUW016967@bari.maths.usyd.edu.au>
References: <1316559903.15093.15.camel@lade.trondhjem.org> <201109202329.p8KNTGUW016967@bari.maths.usyd.edu.au>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: <paul.szabo@sydney.edu.au>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: paul.szabo@sydney.edu.au [mailto:paul.szabo@sydney.edu.au]
> Sent: Tuesday, September 20, 2011 7:29 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Please support NSF squashing multiple groups
> 
> Dear Trond,
> 
> > ... what you are proposing is a potential security problem.
> 
> Yes, definitely: if ever such options were implemented, then potential
users
> should evaluate whether using them (or not using them) introduced a
> security vulnerability. That said...
> 
> NFS security traditionally depended on UIDs and GIDs being "in sync"
> between the server and the clients. My proposal simply would enforce
all
> GIDs to be "in sync" with the UID, as per server view; most often that
would
> be a no-op (except for accesses by setuid or setgid apps).
> 
> Seems that kerberos has no concept of groups but only of "principals"
> which are somewhat like UIDs. My proposal would bring NFSv3 in line
with
> the NFSv4+krb model of "only the UID matters".

That's a model which is incompatible with the way many people use the
AUTH_SYS authentication model.

NFSroot setups etc _rely_ on being able to setgid() at will. They may
also require the group hack in order to work in environments where some
people have > 32 groups.

Basically, the point is this: AUTH_SYS is inherently for use only in
trusted environments. It is too easy to fake a uid or a gid when you use
a protocol that exposes them in clear on the network and without
providing any form of secure integrity checking.

Kerberos is able to go beyond that trusted model (although it too has
limitations - particularly w.r.t. working in an environment where the
client or the server may have been compromised). However Kerberos will
currently limit your ability to setgid. The next generation of
RPCSEC_GSS is expected to lift that particular limitation, and will
allow us to bring kerberos in line with AUTH_SYS (albeit with greater
security) rather than the other way round.

Cheers
  Trond
