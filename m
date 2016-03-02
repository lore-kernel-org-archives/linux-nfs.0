Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34102 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826AbcCBTBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2016 14:01:36 -0500
Date: Wed, 2 Mar 2016 14:01:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 00/14] NFS/RDMA server patches for v4.6
Message-ID: <20160302190134.GB3512@fieldses.org>
References: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
 <20160301220052.GF23792@fieldses.org>
 <A6015E74-BB21-47EE-B100-0C5DC0C67591@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A6015E74-BB21-47EE-B100-0C5DC0C67591@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 02, 2016 at 10:36:42AM -0800, Chuck Lever wrote:
> 
> > On Mar 1, 2016, at 2:00 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> >> On Tue, Mar 01, 2016 at 01:05:14PM -0500, Chuck Lever wrote:
> >> Hi Bruce-
> >> 
> >> I think these are ready for linux-next.
> > 
> > OK, applying for 4.6, thanks.
> 
> Thanks!
> 
> > I still wonder whether the code makes incorrect assumptions about how
> > the server xdr encoder uses the reply xdr_buf.
> 
> Assumptions, probably. I believe these assumptions are the same as are
> made on the client side. It would be awesome to build an API contract
> for struct xdr_buf and have it written down somewhere, then we would
> know for sure.
> 
> 
> > That might only affect
> > clients which constructed rather strange compounds.  And shouldn't be
> > made any worse by these patches.
> 
> You're thinking of clients that might send more than one READ or WRITE
> in and NFSv4 COMPOUND? The thought for the current implementation
> is that the first READ or WRITE operation would be allowed to use the
> xdr_buf page list, and arguments/results for the remaining READ/WRITE
> operations would go inline (ie: a Long Call or Reply with data copy on
> both ends).

Actually once the server realizes a compound is "too complicated" (e.g.,
more than one READ), it just reverts to encoding into the head till it's
full, then the first page, then the second, etc., with no special
treatment for read data.  (Grep for RQ_SPLICE_OK, especially in
fs/nfsd/nfs4xdr.c).

--b.
