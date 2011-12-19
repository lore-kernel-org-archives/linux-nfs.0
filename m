Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:49114 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753050Ab1LSXah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 18:30:37 -0500
Message-ID: <4EEFC8EE.70001@zytor.com>
Date: Mon, 19 Dec 2011 15:29:50 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Dave Chinner <david@fromorbit.com>
CC: Jeremy Allison <jra@samba.org>, Ric Wheeler <ricwheeler@gmail.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
References: <4EE8F75F.6070800@gmail.com> <20111214195931.GC10664@samba2> <4EEFB87F.9000104@zytor.com> <20111219225722.GS23662@dastard>
In-Reply-To: <20111219225722.GS23662@dastard>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/19/2011 02:57 PM, Dave Chinner wrote:
> 
> That was my immediate thought, but sendfile has plumbing that is
> page cache based and we require completely different infrastructure
> and semantics for an array offload.
> 

The plumbing is internal to the kernel and doesn't mean we have to use
the same VFS methods.

> e.g. for an array offload, we have to flush the source file page
> cache first so that the data being copied is known to be on disk,
> then invalidate the destination page cache if overwriting or extend
> and pre-allocate blocks if not. Then we have to map both files and
> hand that off to the array.
> 
> Then there's a whole bunch of tricky questions about what the state
> of the destination file should look like while the copy is in
> progress, whether the source file should be allowed to change (e.g.
> it can't be truncated and have blocks freed and then reused by other
> files half way through the copy offload operation), and so on.
> 
> sendfile() has well known, fixed semantics that we can't change to
> suit what is needed for an offload operation that could potentially
> take hours to complete. Hence I think an new syscall is the way to
> go....

Perhaps what we need first in an explicit enumeration of the semantics
you're looking for.

	-hpa

