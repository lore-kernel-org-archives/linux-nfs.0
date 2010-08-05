From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Write delegation
Date: Wed, 04 Aug 2010 21:25:21 -0400
Message-ID: <1280971521.2865.30.camel@heimdal.trondhjem.org>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
	 <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
	 <97A00951-577C-4365-AA38-3C6E2D03B372@netapp.com>
	 <AANLkTimi9CSa=XfoKBMCm-XAKcVQKVi0bEXgtA+XHexE@mail.gmail.com>
	 <1280956937.2865.13.camel@heimdal.trondhjem.org>
	 <AANLkTi=FivAoO+Rqin82h885_8bj1=Ck5mjqPqV2rif4@mail.gmail.com>
	 <1280969564.2865.23.camel@heimdal.trondhjem.org>
	 <AANLkTinq-q5f5QjCBiXuZMJY6dHajpDPZ7aO55ipNZcE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
To: Yudong Gao <stgyd@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:42096 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162Ab0HEBZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 21:25:28 -0400
In-Reply-To: <AANLkTinq-q5f5QjCBiXuZMJY6dHajpDPZ7aO55ipNZcE-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-08-04 at 18:22 -0700, Yudong Gao wrote:

> But for the integration with NFS, it is confusing. The
> fscache_write_page() is called only in one place:
> nfs_readpage_release(). So a NFS page is only written to fscache after
> it is read from the server in nfs_readpage. So my question is, if a
> page is locally modified, when its data is propagated to fscache? I
> check the nfs_write_begin() and nfs_write_end() but cannot find any
> relative implementation.

See my previous answer. fscache only supports read-only files in NFS.

Trond

