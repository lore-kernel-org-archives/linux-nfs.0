Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:50948 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbAGS2i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 13:28:38 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so6412237pad.9
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 10:28:38 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH v3 03/49] nfs41: pull data server cache from file layout to generic pnfs
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <20150107145609.GA6019@infradead.org>
Date: Wed, 7 Jan 2015 10:28:34 -0800
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <466D2AF3-64E4-4B89-BAE7-228CE1B9FF21@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <1420590534-84063-4-git-send-email-loghyr@primarydata.com> <20150107145609.GA6019@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 7, 2015, at 6:56 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Tue, Jan 06, 2015 at 04:28:08PM -0800, Tom Haynes wrote:
>> From: Peng Tao <tao.peng@primarydata.com>
>> 
>> Also pull nfs4_pnfs_ds_addr and nfs4_pnfs_ds to generic pnfs.
>> 
>> They can all be reused by flexfile layout as well.
> 
> Should this really go into pnfs_dev.c?  It's not as generic as
> the other code handling the device cache.  Maybe there should be
> a pnfs_nfs.c or similar for this code as well as the code moved to
> pnfs_nfsio.c earlier?

While the code moving to pdfs_nfsio.c appears to be earlier, that
actually occurred later in the development process. I.e., it was not
available when this patch occurred.

Having said that, I’m open to pnfs_nfs.c as you suggested. The code
moved to pnfs_nfsio.c was not moved to pnfs_dev.c because I really
did not see it being generic enough as you said.


