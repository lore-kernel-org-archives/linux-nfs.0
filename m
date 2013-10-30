Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682Ab3J3Qit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Oct 2013 12:38:49 -0400
Date: Wed, 30 Oct 2013 12:38:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/8] simplify reconnecting dentries looked up by
 filehandle (v2)
Message-ID: <20131030163823.GA31550@pad.fieldses.org>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
 <20131030161013.GA19668@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131030161013.GA19668@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 30, 2013 at 09:10:13AM -0700, Christoph Hellwig wrote:
> The whole series looks good to me,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks.  I've added that to the for-viro branch at:

	git://linux-nfs.org/~bfields/linux.git for-viro

So that now includes:

	- delegation support
	- jlayton's fix for a setlease/open race
	- 32/64-bit filehandle lookup fix
	- fixes for some uses of DCACHE_DISCONNECTED
	- this path_reconnect cleanup

As far as I'm concerned all of that is ready for 3.13.


I still intend to contribute a basic open_by_fhandle_at test but haven't
gotten much past running xfstests/new.

And as you said it would also be nice to have stress testing that tries
to trigger the various reconnect/rename/rmdir races, but I haven't
thought much yet about how to do that.

--b.
