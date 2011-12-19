Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:2873 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751610Ab1LSXCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2011 18:02:30 -0500
Date: Tue, 20 Dec 2011 09:57:22 +1100
From: Dave Chinner <david@fromorbit.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Jeremy Allison <jra@samba.org>, Ric Wheeler <ricwheeler@gmail.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111219225722.GS23662@dastard>
References: <4EE8F75F.6070800@gmail.com>
 <20111214195931.GC10664@samba2>
 <4EEFB87F.9000104@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EEFB87F.9000104@zytor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2011 at 02:19:43PM -0800, H. Peter Anvin wrote:
> On 12/14/2011 11:59 AM, Jeremy Allison wrote:
> >>
> >> Can we resurrect this effort? Is copyfile() still a good way to go,
> >> or should we look at other hooks?
> > 
> > Windows uses a COPYCHUNK call, which specifies the
> > following parameters:
> > 
> > Definition of a copy "chunk":
> > 
> > hyper source_off;
> > hyper target_off;
> > uint32 length;
> > 
> > and an array of these chunks which is passed
> > into their kernel.
> > 
> > This is what we have to implement in Samba.
> > 
> 
> Could we do this by (re-)allowing sendfile() between two files?

That was my immediate thought, but sendfile has plumbing that is
page cache based and we require completely different infrastructure
and semantics for an array offload.

e.g. for an array offload, we have to flush the source file page
cache first so that the data being copied is known to be on disk,
then invalidate the destination page cache if overwriting or extend
and pre-allocate blocks if not. Then we have to map both files and
hand that off to the array.

Then there's a whole bunch of tricky questions about what the state
of the destination file should look like while the copy is in
progress, whether the source file should be allowed to change (e.g.
it can't be truncated and have blocks freed and then reused by other
files half way through the copy offload operation), and so on.

sendfile() has well known, fixed semantics that we can't change to
suit what is needed for an offload operation that could potentially
take hours to complete. Hence I think an new syscall is the way to
go....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
