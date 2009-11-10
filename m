From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH] client cannot get lock after other client got
 lock occur network partition.
Date: Tue, 10 Nov 2009 21:35:49 +0900
Message-ID: <1257856550.3046.6.camel@heimdal.trondhjem.org>
References: <4AF7DEAB.20202@cn.fujitsu.com>
	 <1257772609.3754.11.camel@heimdal.trondhjem.org>
	 <4AF934A1.9040908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55715 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109AbZKJMfw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2009 07:35:52 -0500
In-Reply-To: <4AF934A1.9040908@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-11-10 at 17:38 +0800, Mi Jinlong wrote:
> Hi Trond
>=20
> Trond Myklebust =E5=86=99=E9=81=93:
> > On Mon, 2009-11-09 at 17:19 +0800, Mi Jinlong wrote:
> >> Hi Trond et all
> >>
> >> There is a bug, when i test NFSv3 file's lock as followed:
> >>
> >> Step1: ClientA and ClientB open a same nfs file;
> >> Step2: ClientA locks file with write lock, it's ok;
> >> Step3: Cut off the network between ClientA and Server;
> >> Step4: ClientB can not acquire for write lock successful forever, =
even though
> >>        the network partition larger than NLM_HOST_EXPIRE.
> >>
> >> As i know, If use NFSv4, step4 can success after LEASE_TIME.
> >>
> >> Is it necessary to fix NFSv3 ?=20
> >>
> >> The attached patch can make this case OK, but i am not sure it's g=
ood.
> >=20
> > Unfortunately, NLM (the NFSv2 and v3 locking protocol) is not lease
> > based, so the above scenario is truly an unfixable one.
> >=20
> > The problem with applying your patch is, in essence, that we risk
> > breaking another scenario where a client grabs a lock, and then hol=
ds it
> > for a while.
> > The reason this breaks is that there is no equivalent in the NLM
> > protocol of the NFSv4 RENEW operation to tell the server that "This
> > client is still alive and wants you to keep its state".
>=20
> Thanks for your answer!
>=20
> This bug seems serious, shouldn't we fix it?

Unless you can think of a fix which works with the current NLM protocol=
,
I'd suggest simply encouraging people to move to a protocol with lease
based locks: i.e. NFSv4...

Cheers
  Trond

