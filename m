Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42305 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932553AbcHKQZW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 12:25:22 -0400
Date: Thu, 11 Aug 2016 18:25:21 +0200
From: hch <hch@lst.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Thomas Haynes <loghyr@primarydata.com>, hch <hch@lst.de>,
        Fields Bruce James <bfields@fieldses.org>
Subject: Re: CB_LAYOUTRECALL "deadlock" with in-kernel flexfiles server and
	XFS
Message-ID: <20160811162521.GA24116@lst.de>
References: <1470929036.30238.14.camel@redhat.com> <CA55873C-4CF9-42F8-A35E-07C9CB685800@primarydata.com> <1470931603.30238.25.camel@redhat.com> <66A7F612-4704-43CB-AE93-6C1A8A52D6DA@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <66A7F612-4704-43CB-AE93-6C1A8A52D6DA@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yeah, for file-like layouts there should be a flag in
struct nfsd4_layout_ops to disable recalls.
