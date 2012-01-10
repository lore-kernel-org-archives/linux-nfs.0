Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:38055 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751984Ab2AJKxy convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 05:53:54 -0500
From: Wolfgang Walter <wolfgang.walter@stwm.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes and cleanups
Date: Tue, 10 Jan 2012 11:53:50 +0100
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <1326142671.9041.1.camel@lade.trondhjem.org> <201201100149.00716.wolfgang.walter@stwm.de> <1326160381.13527.4.camel@lade.trondhjem.org>
In-Reply-To: <1326160381.13527.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201201101153.51438.wolfgang.walter@stwm.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Dienstag, 10. Januar 2012 schrieb Trond Myklebust:
> On Tue, 2012-01-10 at 01:49 +0100, Wolfgang Walter wrote:
> > On Monday 09 January 2012, Trond Myklebust wrote:
> > > On Mon, 2012-01-09 at 14:28 -0800, Myklebust, Trond wrote:
> > > > > -----Original Message-----
> > > >
> > > > Please read the changelog and documentation:
> > > >
> > > > If your server doesn’t support numeric uids/gids, then you will see
> > > > _no_ change in behaviour.
> >
> > Hmm, what does that mean exactly? Does a linux nfs4-server support
> > numeric uids/gids? If yes, by default or do I need do set an option?
>
> The patch requires no changes to a configuration that is already
> working. That's the whole point I've been trying to get across.

So if user foo has uid 500 on the server and uid 600 on the client that will 
still work with AUTH_SYS:

client: uid 500 => foo@REALM
server: foo@REALM => uid 600

and vice-versa?

> > I always thought that the idmapper with its translation were exactly for
> > that case. If I have a homogenous uid/gid name space why would I want to
> > use names and translate anyway?
>
> For RPCSEC_GSS authentication. That's the only case that the original
> RFC3530 cared about. The problems arise when people use AUTH_SYS, and
> this protocol change+patch is the solution.


Regards,
-- 
Wolfgang Walter
Studentenwerk München
Anstalt des öffentlichen Rechts
Abteilungsleiter IT
Leopoldstraße 15
80802 München
Tel: +49 89 38196 276
Fax: +49 89 38196 150
Email: wolfgang.walter@stwm.de
http://www.studentenwerk-muenchen.de/
