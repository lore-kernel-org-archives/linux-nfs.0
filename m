Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:45741 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933496Ab1J2RsJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 13:48:09 -0400
Subject: Re: nfsd4_is_junction
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111029101649.GA12345@infradead.org>
Date: Sat, 29 Oct 2011 13:47:55 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <929DFFCE-F92B-4EF6-8C9E-E807AB4FFA9C@oracle.com>
References: <20111029101649.GA12345@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2011, at 6:16 AM, Christoph Hellwig wrote:

> This function should probably grow a check for S_NOSEC instead of
> hitting the filesystems with an xattr read for every lookup.

It doesn't perform the xattr read on _every_ lookup, but only when the object has a special set of permission bits.

But actually, it probably doesn't need that 'type" attribute check at all.  It should delegate that check to mountd.  I assume many of those upcalls would hit in the export cache anyway?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




