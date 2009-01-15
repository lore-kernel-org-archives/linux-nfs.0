From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: a suspected bug in nfs_free_seqid()
Date: Thu, 15 Jan 2009 18:38:11 -0500
Message-ID: <1232062691.6986.4.camel@heimdal.trondhjem.org>
References: <2014bcab0901150253p6941a323g5809c98c21e31122@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: =?UTF-8?Q?=ED=99=8D=EC=8B=A0?= shin hong <hongshin@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39717 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759881AbZAOXiQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jan 2009 18:38:16 -0500
In-Reply-To: <2014bcab0901150253p6941a323g5809c98c21e31122-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-01-15 at 19:53 +0900, =ED=99=8D=EC=8B=A0 shin hong wrote:
> Hi. I found a suspected bug while I review nfs_free_seqid() in nfs4st=
ate.c
>=20
> It seems that nfs_free_seqid() tried to use "test and test-set" idiom
> (double checked locking)
> but the second "test" is missed so that It may occur data race when
> other thread makes
> &seqid->list not empty before the thread executiong nfs_free_seqid()
> holds spin_lock(&sequence->lock) after checking !list_empty(&seqid->l=
ist).
>=20
> I do not have much background for nfs so that it might not be a real =
bug
> so please review the code and let me know whether it is real one or n=
ot.
> Thanks.

Hi,

Unlike the struct rpc_sequence, the struct nfs_seqid is always owned by
a single process, so there is no race here.

Cheers
  Trond

