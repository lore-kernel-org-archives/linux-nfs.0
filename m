From: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Subject: Re: atimes not updated over NFS
Date: Wed, 30 Jan 2008 13:13:20 +0100
Message-ID: <20080130121320.GU17213@aym.net2.nerim.net>
References: <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org> <20080129083402.GN15220@kernel.dk> <20080129182721.GB28032@fieldses.org> <20080129183042.GH15220@kernel.dk> <20080129203713.GS17213@aym.net2.nerim.net> <20080130112300.GP15220@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-103-wednesday.noc.nerim.net ([62.4.17.103]:4223 "EHLO
	mallaury.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753146AbYA3MNY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2008 07:13:24 -0500
In-Reply-To: <20080130112300.GP15220@kernel.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008-01-30 12:23 +0100, Jens Axboe wrote:
> On Tue, Jan 29 2008, Andre Majorel wrote:
> > On 2008-01-29 19:30 +0100, Jens Axboe wrote:
> >=20
> > > diff --git a/fs/splice.c b/fs/splice.c
> > > index 0a0b79b..504a096 100644
> > > --- a/fs/splice.c
> >=20
> > Does the (bytes > 0) test mean that read(2) on an empty file will
> > not update the atime ? Not a big deal for me personally, but that
> > would be inconsistent with local file system behaviour.
>=20
> Good point, I'll commit a fixup for that patch.

Excellent. Thanks to everyone involved.

--=20
Andr=E9 Majorel <URL:http://www.teaser.fr/~amajorel/>
Do not use this account for regular correspondence.
See the URL above for contact information.
