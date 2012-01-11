Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:36048 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933025Ab2AKPb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 10:31:29 -0500
Date: Wed, 11 Jan 2012 10:31:25 -0500
From: "Ted Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Dilger <adilger@whamcloud.com>, linux-nfs@vger.kernel.org,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        ext4 development <linux-ext4@vger.kernel.org>,
        linux-fsdevel Devel <linux-fsdevel@vger.kernel.org>,
        Fan Yong <yong.fan@whamcloud.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Eric Sandeen <sandeen@redhat.com>
Subject: Re: [PATCH 0/4] [RESEND] 32/64 bit llseek hashes (v5)
Message-ID: <20120111153125.GC4589@thunk.org>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain>
 <B5CFE283-4C3A-4C05-A779-05E2BE2EF5C6@whamcloud.com>
 <20120111144827.GA32381@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120111144827.GA32381@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 11, 2012 at 09:48:27AM -0500, J. Bruce Fields wrote:
> 
> Yes, this needs to be fixed--is there anything in particular holding up
> these patches?

Yes, I need more people reviewing ext4 patches, so it's not me doing
all of the review.  :-)

I will put this on my "high priority to review ASAP for the next merge
window" list.

						- Ted
