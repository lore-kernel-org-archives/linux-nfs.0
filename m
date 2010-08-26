From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: hang in writeback code on nfsv4 mount
Date: Thu, 26 Aug 2010 16:20:33 +0300
Message-ID: <1282828834.24044.289.camel@localhost>
References: <20100825023425.GA24591@fieldses.org>
	 <1282717945.24044.187.camel@localhost>
	 <20100825154451.GB14440@fieldses.org>
	 <1282821851.24044.284.camel@localhost>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <jaxboe@fusionio.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64376 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab0HZNV5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 09:21:57 -0400
Received: by fxm13 with SMTP id 13so1238247fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Aug 2010 06:21:56 -0700 (PDT)
In-Reply-To: <1282821851.24044.284.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-08-26 at 14:24 +0300, Artem Bityutskiy wrote:
> On Wed, 2010-08-25 at 11:44 -0400, J. Bruce Fields wrote:
> > > sudo mount -t nfs4 sauron:/home/dedekind/ /mnt/sauron_home/
> > >=20
> > > works fine. Any hints about how to reproduce this are welcome.
> >=20
> > Huh.  The simple mount hits it every time for me.  I'll investigate=
 some
> > more.
>=20
> Ok, I can reproduce something which looks like memory corruption for =
me:

Err, scratch this please, this was my debugging code which I injected.
Still trying to reproduce...

--=20
Best Regards,
Artem Bityutskiy (=D0=90=D1=80=D1=82=D1=91=D0=BC =D0=91=D0=B8=D1=82=D1=8E=
=D1=86=D0=BA=D0=B8=D0=B9)

