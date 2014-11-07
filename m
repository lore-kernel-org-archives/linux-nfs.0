Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ppsw-50.csi.cam.ac.uk ([131.111.8.150]:33878 "EHLO
	ppsw-50.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbaKGEm1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2014 23:42:27 -0500
Subject: Re: [PATCH v5 7/7] add a flag for per-operation O_DSYNC semantics
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
From: Anton Altaparmakov <aia21@cam.ac.uk>
In-Reply-To: <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
Date: Fri, 7 Nov 2014 06:22:48 +0200
Cc: Milosz Tanski <milosz@adfin.com>, linux-kernel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>, Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-aio@kvack.org,
        Mel Gorman <mgorman@suse.de>,
        Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-api@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
        linux-arch@vger.kernel.org, ceph-devel@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        ocfs2-devel@oss.oracle.com, linux-mm@kvack.org
Message-Id: <BF30FAEC-D4D3-4079-9ECD-2743747279BD@cam.ac.uk>
References: <cover.1415220890.git.milosz@adfin.com> <cover.1415220890.git.milosz@adfin.com> <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com> <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
To: Jeff Moyer <jmoyer@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

> On 7 Nov 2014, at 01:46, Jeff Moyer <jmoyer@redhat.com> wrote:
> 
> Milosz Tanski <milosz@adfin.com> writes:
> 
>> -		if (type == READ && (flags & RWF_NONBLOCK))
>> -			return -EAGAIN;
>> +		if (type == READ) {
>> +			if (flags & RWF_NONBLOCK)
>> +				return -EAGAIN;
>> +		} else {
>> +			if (flags & RWF_DSYNC)
>> +				return -EINVAL;
>> +		}
> 
> Minor nit, but I'd rather read something that looks like this:
> 
> 	if (type == READ && (flags & RWF_NONBLOCK))
> 		return -EAGAIN;
> 	else if (type == WRITE && (flags & RWF_DSYNC))
> 		return -EINVAL;

But your version is less logically efficient for the case where "type == READ" is true and "flags & RWF_NONBLOCK" is false because your version then has to do the "if (type == WRITE" check before discovering it does not need to take that branch either, whilst the original version does not have to do such a test at all.

Best regards,

	Anton

> I won't lose sleep over it, though.
> 
> Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
University of Cambridge Information Services, Roger Needham Building
7 JJ Thomson Avenue, Cambridge, CB3 0RB, UK

