From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH -next] nfs: fix ISO C90 warning
Date: Thu, 17 Dec 2009 16:58:13 -0500
Message-ID: <1261087093.4080.36.camel@localhost>
References: <20091215165309.58e98eea.sfr@canb.auug.org.au>
	 <20091216142334.6a0ba115.randy.dunlap@oracle.com>
	 <1261003219.13878.6.camel@localhost>
	 <20091216144700.34b80b4b.randy.dunlap@oracle.com>
	 <alpine.LFD.2.00.0912162355350.2755@localhost.localdomain>
	 <1261004497.13878.9.camel@localhost>
	 <2375c9f90912170200m12a5310cg90343c5c1081fbb8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:43225 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbZLQV60 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 16:58:26 -0500
In-Reply-To: <2375c9f90912170200m12a5310cg90343c5c1081fbb8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-12-17 at 18:00 +0800, Am=C3=A9rico Wang wrote:=20
> Hi,
> Check that currently all usages of RPC_DEBUG are the same,
> we can replace them all.
>=20
> What do you think about the attached patch?
>=20
> Sorry for attaching it, I have a bad mail environment here.
>=20
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

Doesn't that approach instead lead to a lot of 'unreferenced variable'
warnings in the '#undef RPC_DEBUG' case?

Cheers
  Trond

