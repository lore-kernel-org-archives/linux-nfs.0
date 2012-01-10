Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26608 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755673Ab2AJNi5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2012 08:38:57 -0500
Message-ID: <1326202733.2477.32.camel@lade.trondhjem.org>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes and cleanups
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Tue, 10 Jan 2012 08:38:53 -0500
In-Reply-To: <201201101153.51438.wolfgang.walter@stwm.de>
References: <1326142671.9041.1.camel@lade.trondhjem.org>
	 <201201100149.00716.wolfgang.walter@stwm.de>
	 <1326160381.13527.4.camel@lade.trondhjem.org>
	 <201201101153.51438.wolfgang.walter@stwm.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-01-10 at 11:53 +0100, Wolfgang Walter wrote: 
> Am Dienstag, 10. Januar 2012 schrieb Trond Myklebust:
> > On Tue, 2012-01-10 at 01:49 +0100, Wolfgang Walter wrote:
> > > On Monday 09 January 2012, Trond Myklebust wrote:
> > > > On Mon, 2012-01-09 at 14:28 -0800, Myklebust, Trond wrote:
> > > > > > -----Original Message-----
> > > > >
> > > > > Please read the changelog and documentation:
> > > > >
> > > > > If your server doesn’t support numeric uids/gids, then you will see
> > > > > _no_ change in behaviour.
> > >
> > > Hmm, what does that mean exactly? Does a linux nfs4-server support
> > > numeric uids/gids? If yes, by default or do I need do set an option?
> >
> > The patch requires no changes to a configuration that is already
> > working. That's the whole point I've been trying to get across.
> 
> So if user foo has uid 500 on the server and uid 600 on the client that will 
> still work with AUTH_SYS:
> 
> client: uid 500 => foo@REALM
> server: foo@REALM => uid 600

No. In the scenario you describe above, it will be

client: uid 600 <=> foo@REALM
server: foo@REALM <=> uid 500

> and vice-versa?

The above _not_ work properly in the existing code... This kind of
situation is the whole reason for wanting to change the existing code.

With the existing code, the client will send numeric uid 600 as part of
the rpc-level AUTH_SYS authentication, and so the server will create
files with uid 600 irrespective of the foo@REALM idmapping at the NFSv4
level.
When the client later attempts to do a GETATTR on that file, the server
will then translate that uid 600 using the idmapper

server  uid 600 => bar@REALM
client  bar@REALM => uid 213412

IOW: This is exactly the situation where we want to use numeric uids
everywhere, so that the server returns a numeric uid 600 in the GETATTR.
In addition, if the client does a 'chown foo', it should send uid 600 in
the SETATTR request, which matches the uid 600 in the AUTH_SYS
authentication.

Or again: If I'm using AUTH_SYS, then I'm transmitting numeric uids/gids
as my authentication token, and so I want to use the same numeric
uids/gids to label my file ownership. The idmapper doesn't affect the
AUTH_SYS authentication token, and so mapping the NFS ownership to
trond@REALM is not useful and may instead result in wrong behaviour such
as in the situation described above.

When I use KerberosV principals ('kinit trond@REALM') as my
authentication token in an RPCSEC_GSS session, then I want to use the
same _string_ user trond@REALM to label my file ownership. The idmapper
is then used to map the abstract trond@REALM into a uid/gid that the
kernel can understand (and the actual value on the client/server is
irrelevant as long as it matches whatever the authentication token maps
to).


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

