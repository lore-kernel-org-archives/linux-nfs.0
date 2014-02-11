Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41029 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435AbaBKWeC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 17:34:02 -0500
Date: Tue, 11 Feb 2014 17:33:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: fix acl buffer overrun
Message-ID: <20140211223351.GC22695@fieldses.org>
References: <20140208204522.GG8801@fieldses.org>
 <20140209020933.GA23163@fieldses.org>
 <20140211193801.GA22695@fieldses.org>
 <20140211202548.GA21844@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140211202548.GA21844@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 11, 2014 at 12:25:48PM -0800, Christoph Hellwig wrote:
> Looks good and sorry for the regression.

Well, my fault for not reviewing the patch, I saw it and didn't give it
more than a skim.  Not sure I would have caught that, though.

The only thing I can think of that might have made it easier to catch
was breaking up the patch (v4 could probably have been done separately
from v2/v3?).  But I still probably would've overlooked it....

--b.
