Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46232 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751538AbdBTRPW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Feb 2017 12:15:22 -0500
Date: Mon, 20 Feb 2017 12:15:19 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Dros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
Message-ID: <20170220171519.GE12335@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-7-git-send-email-bfields@redhat.com>
 <1D136924-2EC7-4CF3-8250-98799DFBEB3F@oracle.com>
 <20170220160940.GB12335@parsley.fieldses.org>
 <4824B968-4ED6-44AA-A935-3D309D76EFFF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4824B968-4ED6-44AA-A935-3D309D76EFFF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 20, 2017 at 11:42:31AM -0500, Chuck Lever wrote:
> 
> > On Feb 20, 2017, at 11:09 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > On Sun, Feb 19, 2017 at 02:29:03PM -0500, Chuck Lever wrote:
> >> 
> >>> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >>> 
> >>> From: Weston Andros Adamson <dros@netapp.com>
> >>> 
> >>> Instead of preallocating pags, allow xdr_partial_copy_from_skb() to
> >>> allocate whatever pages we need on demand.  This is what the NFSv3 ACL
> >>> code does.
> >> 
> >> The patch description does not explain why this change is
> >> being done.
> > 
> > The only justification I see is avoiding allocating pages unnecessarily.
> 
> That makes sense. Is there a real world workload that has seen
> a negative effect?
> 
> 
> > Without this patch, for each getacl, we allocate 17 pages (if I'm
> > calculating correctly) and probably rarely use most of them.
> > 
> > In the v3 case I think it's 7 pages instead of 17.
> 
> I would have guessed 9. Out of curiosity, is there a reason
> documented for these size limits?


In the v4 case: 

	#define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)

And I believe XATTR_SIZE_MAX is a global maximum on the size of any
extend attribute value.

In the v3 case:

	/* Maximum number of ACL entries over NFS */
	#define NFS_ACL_MAX_ENTRIES     1024

	#define NFSACL_MAXPAGES         ((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
	                                 >> PAGE_SHIFT)

No idea where that 1024 comes from.

--b.
