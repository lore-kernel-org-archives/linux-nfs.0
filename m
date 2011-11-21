Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55636 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610Ab1KUNfj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Nov 2011 08:35:39 -0500
Date: Mon, 21 Nov 2011 08:35:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Christoph Hellwig <hch@infradead.org>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Andreas Dilger <adilger@dilger.ca>
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Message-ID: <20111121133521.GB656@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111019222021.GB1874@fieldses.org>
 <87k4805alx.fsf@linux.vnet.ibm.com>
 <20111020091434.GC5444@fieldses.org>
 <20111020091946.GA23773@infradead.org>
 <87aa8w53kj.fsf@linux.vnet.ibm.com>
 <20111020174915.GA9987@fieldses.org>
 <m1y5vcxxzp.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1y5vcxxzp.fsf@fess.ebiederm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 19, 2011 at 01:28:10AM -0800, Eric W. Biederman wrote:
> Thanks for the cc.  After looking at the user namespace issues it looks
> like the sane thing is really to map the user namespace uids into
> appropriate uids for storing on the filesystem.  Anything else
> seems to be a lot of pain for very little gain.
> 
> If a filesystem went as far as storing string ids.  I think I would
> be happy to use different domains for different user namespaces, but
> for anything else I just don't see the point.
> 
> What it does look like to me is that at some point we will want to
> support > 32bit uids.  There are 7 billion people on the planet and we
> only have 4 billion user ids.  The biggest individual organization have
> 3 million users, which keeps us safe for now.  However my forecast is
> each user namespace is going to wind up giving each user a bunch of
> uids.  That will accelerate the point at which we find 32bit uids tight.
> How fast being generous and assigning 10k uids per user is going to get
> us into trouble I don't know. 

Yes, bigger uid's make sense to me.

But at the point when we make that transition I think updating the ACL
format will be the least of our troubles.  So I think we'll leave it
alone rather than try to guess the right type now.

--b.
