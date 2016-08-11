Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42495 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932489AbcHKQ7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 12:59:04 -0400
Date: Thu, 11 Aug 2016 18:59:02 +0200
From: hch <hch@lst.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: hch <hch@lst.de>, Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Thomas Haynes <loghyr@primarydata.com>,
        Fields Bruce James <bfields@fieldses.org>
Subject: Re: CB_LAYOUTRECALL "deadlock" with in-kernel flexfiles server and
	XFS
Message-ID: <20160811165902.GA25717@lst.de>
References: <1470929036.30238.14.camel@redhat.com> <CA55873C-4CF9-42F8-A35E-07C9CB685800@primarydata.com> <1470931603.30238.25.camel@redhat.com> <66A7F612-4704-43CB-AE93-6C1A8A52D6DA@primarydata.com> <20160811162521.GA24116@lst.de> <1470933227.30238.35.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1470933227.30238.35.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 11, 2016 at 12:33:47PM -0400, Jeff Layton wrote:
> On Thu, 2016-08-11 at 18:25 +0200, hch wrote:
> > Yeah, for file-like layouts there should be a flag in
> > struct nfsd4_layout_ops to disable recalls.
> 
> I don't think disabling recalls would be enough, would it? XFS still
> wants to break_layout and won't proceed until the layout list is empty,
> AFAICT. We need some way to indicate to the lower filesystem not to
> call break_layout in this case.

XFS only cares about block-like layours where the client has direct
access to the file blocks.  I'd need to look how to propagate the
flag into break_layout, but in principle we don't need to do any
recalls on truncate every for file and flexfile layouts.

> 
> -- 
> Jeff Layton <jlayton@redhat.com>
---end quoted text---
