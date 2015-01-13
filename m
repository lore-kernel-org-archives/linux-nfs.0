Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f178.google.com ([209.85.160.178]:48634 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbAMTsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 14:48:10 -0500
Received: by mail-yk0-f178.google.com with SMTP id 20so2313060yks.9
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 11:48:10 -0800 (PST)
Date: Tue, 13 Jan 2015 11:48:04 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 03/49] nfs41: pull data server cache from file layout
 to generic pnfs
Message-ID: <20150113194804.GD90833@kitty>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <1420590534-84063-4-git-send-email-loghyr@primarydata.com>
 <20150107145609.GA6019@infradead.org>
 <466D2AF3-64E4-4B89-BAE7-228CE1B9FF21@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <466D2AF3-64E4-4B89-BAE7-228CE1B9FF21@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2015 at 10:28:34AM -0800, Tom Haynes wrote:
> 
> > On Jan 7, 2015, at 6:56 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > On Tue, Jan 06, 2015 at 04:28:08PM -0800, Tom Haynes wrote:
> >> From: Peng Tao <tao.peng@primarydata.com>
> >> 
> >> Also pull nfs4_pnfs_ds_addr and nfs4_pnfs_ds to generic pnfs.
> >> 
> >> They can all be reused by flexfile layout as well.
> > 
> > Should this really go into pnfs_dev.c?  It's not as generic as
> > the other code handling the device cache.  Maybe there should be
> > a pnfs_nfs.c or similar for this code as well as the code moved to
> > pnfs_nfsio.c earlier?
> 
> While the code moving to pdfs_nfsio.c appears to be earlier, that
> actually occurred later in the development process. I.e., it was not
> available when this patch occurred.
> 
> Having said that, I’m open to pnfs_nfs.c as you suggested. The code
> moved to pnfs_nfsio.c was not moved to pnfs_dev.c because I really
> did not see it being generic enough as you said.
> 

Okay, the v4 patchset will apply this change.
