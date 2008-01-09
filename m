From: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Subject: Re: atimes not updated over NFS
Date: Thu, 10 Jan 2008 00:51:53 +0100
Message-ID: <20080109235153.GI9212@aym.net2.nerim.net>
References: <20080109101313.GG9212@aym.net2.nerim.net> <1199892437.11141.2.camel@heimdal.trondhjem.org> <20080109223748.GH9212@aym.net2.nerim.net> <1199920996.7638.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-dmz-233-wednesday.dmz.nerim.net ([195.5.254.233]:53880
	"EHLO kellthuzad.dmz.nerim.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753126AbYAIXx7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 18:53:59 -0500
Received: from kraid.nerim.net (smtp-103-wednesday.nerim.net [62.4.16.103])
	by kellthuzad.dmz.nerim.net (Postfix) with ESMTP id 9E36115E45
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jan 2008 00:53:47 +0100 (CET)
In-Reply-To: <1199920996.7638.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008-01-09 18:23 -0500, Trond Myklebust wrote:
> On Wed, 2008-01-09 at 23:37 +0100, Andre Majorel wrote:
>
> > I'll take your word for it. However, let me assure you that atimes
> > somehow used to work over NFS, even for files small enough to fit
> > in the cache. Had they been broken, I would have known. I use Mutt.
>=20
> How would the server know to update the atime? If the file is in cach=
e
> we don't READ.

You tell me. All I can tell you is that Mutt used to work so
atimes were updated one way or another.

As of 2.6.23, access times are never updated, even for files that
are too big to fit in the cache. I'm willing to run tests if that
helps.

--=20
Andr=E9 Majorel <URL:http://www.teaser.fr/~amajorel/>
Do not use this account for regular correspondence.
See the URL above for contact information.
