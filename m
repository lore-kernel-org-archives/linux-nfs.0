Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:24241 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933606Ab1J2R6U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 13:58:20 -0400
Subject: Re: nfsd4_is_junction
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111029175548.GB12122@fieldses.org>
Date: Sat, 29 Oct 2011 13:58:02 -0400
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Message-Id: <7A873A96-ED05-4904-8470-E169B233E951@oracle.com>
References: <20111029101649.GA12345@infradead.org> <929DFFCE-F92B-4EF6-8C9E-E807AB4FFA9C@oracle.com> <20111029175548.GB12122@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2011, at 1:55 PM, J. Bruce Fields wrote:

> On Sat, Oct 29, 2011 at 01:47:55PM -0400, Chuck Lever wrote:
>> 
>> On Oct 29, 2011, at 6:16 AM, Christoph Hellwig wrote:
>> 
>>> This function should probably grow a check for S_NOSEC instead of
>>> hitting the filesystems with an xattr read for every lookup.
>> 
>> It doesn't perform the xattr read on _every_ lookup, but only when the object has a special set of permission bits.
>> 
>> But actually, it probably doesn't need that 'type" attribute check at all.  It should delegate that check to mountd.  I assume many of those upcalls would hit in the export cache anyway?
> 
> You're suggesting doing an upcall on every path that passes the mode-bit
> checks?
> 
> You'd end up populating the export cache with every path that passes
> the mode-bit checks.  I don't think that's a good idea.

You just finished telling us that the mode bit checks would prevent doing an attribute read too often.  Again, how often do we think there will be directories with no execute bits set and the sticky bit set?  I think that's going to be exceptionally rare.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




