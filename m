Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35690 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755063Ab0LOUTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 15:19:12 -0500
Date: Wed, 15 Dec 2010 15:19:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101215201908.GB9646@fieldses.org>
References: <1291869437.2821.6.camel@heimdal.trondhjem.org>
 <20101214233843.GB836@hostway.ca>
 <20101215011021.GA24594@hostway.ca>
 <20101215015609.GB24594@hostway.ca>
 <20101215180813.GA7773@fieldses.org>
 <1292437333.3068.14.camel@heimdal.trondhjem.org>
 <20101215183816.GB7773@fieldses.org>
 <1292441630.3068.55.camel@heimdal.trondhjem.org>
 <20101215194956.GA9646@fieldses.org>
 <1292443028.3068.60.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292443028.3068.60.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 15, 2010 at 02:57:08PM -0500, Trond Myklebust wrote:
> On Wed, 2010-12-15 at 14:49 -0500, J. Bruce Fields wrote:
> > On Wed, Dec 15, 2010 at 02:33:50PM -0500, Trond Myklebust wrote:
> > > 1) The user is authenticating using uids and gids (AUTH_SYS). In that
> > > case, the server is using those uids and gids to authorise user
> > > behaviour, and so file/directory creation/access/deletion/... will
> > > depend only on the numeric values of those uids and gids. It doesn't
> > > matter if the client belongs to a different domain, 'cos AUTH_SYS has no
> > > concept of a domain. It doesn't matter whether or mot there exists a
> > > name@domain mapping on the client, and server. Only the numbers matter.
> > > NFSv2 and NFSv3 got this case right, and NFSv4 got it wrong (or didn't
> > > consider it).
> > > 
> > > 2) The user is authenticating using a principal name@DOMAIN. In this
> > > case, either there is a mapping between name@DOMAIN and a owner@domain
> > > +groupname@domain on the server, or there isn't. In the latter case, the
> > > server treats the principal as the anonymous user. In the former case,
> > > then if the client and server map owner@domain and groupname@domain to
> > > the same uid and gid, then it is safe to pass uids and gids back and
> > > forth. If they don't have identical mappings, then it is still safe to
> > > pass owner@domain and groupname@domain,
> >  
> > Not necessarily; for example, there could be just a one-off mapping
> > between root/client@DOMAIN and root on the server.  And that would be
> > sufficient to do something like a dumb
> > 
> > 	cp -ax / /nfs
> > 
> > backup, where you're just saving/restoring id's using chown/stat.
> > 
> > I don't know if those sorts of cases are common.  But they work under
> > v3, and I don't see a reason to break them on upgrade to v4.
> 
> See above. It's about fixing what is broken with NFSv3.

The practical result in this particular example would be to break
something under NFSv4 that worked under NFSv3.

Could you give an example of a case in which all of the following are
true?:
	- the administrator explicitly requests numeric id's (for
	  example by setting nfs4_disable_idmapping).
	- numeric id's work as long as the client uses auth_sys.
	- they no longer work if that same client switches to krb5.

If so, that would help me to understand why switching automatically from
numeric to string-based uid's in this case would be useful.

> > Certainly I don't see any motivation for going out of our way to break
> > that case when an administrator explicitly requests numeric id's.
> 
> What do you mean by 'explicitly requests numeric ids'?

For example, if they set "nfs4_disable_idmapping".

> If you mean 'decides to use NFSv3' then that works today.
> 
> What is the point of bending over backwards to make NFSv4 bug-compatible
> with NFSv3?

The advantage of supporting numeric user id's would be that it would
allow upgrades from NFSv3 to NFSv4 which would be transparent to the
user in more cases.

> If people want NFSv3 they can use it. You can even mount an
> NFSv3 partition while someone else is using NFSv4 on the same machine.

NFSv4 also has other advantages, which we would like to be able to bring
to people without requiring them to jump through unnecessary hoops.

--b.
