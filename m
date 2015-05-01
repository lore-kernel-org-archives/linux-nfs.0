Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39884 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbbEARXs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 13:23:48 -0400
Date: Fri, 1 May 2015 10:23:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH, RFC] backchannel overflows
Message-ID: <20150501172345.GB29624@infradead.org>
References: <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
 <20150429151404.GA12936@infradead.org>
 <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
 <20150429173454.GA23284@fieldses.org>
 <20150430062558.GA25660@infradead.org>
 <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
 <20150430143731.GA22038@infradead.org>
 <CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com>
 <20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com>
 <E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 30, 2015 at 01:41:02PM -0400, Chuck Lever wrote:
> We discussed this briefly during the Linux NFS town hall meeting.
> I agree using dynamic slot allocation for TCP is fine, and RPC/RDMA
> can use simple overprovisioning.
> 
> This way the upper layer (NFSv4.1 client) doesn?t have to be aware of
> limitations in the RPC layer mechanism.
> 
> Trond may have an additional concern that I didn?t capture.

The other option would be to simply overallocate in the transport layer,
as that is the layer which causes the problem to start with.

That being said, what is the argument for doing any sort of static
allocation here?  I'm fine with doing fully dynamic allocation if that
works out fine, but a mixed static / dynamic allocation sounds like a
nightmare.
