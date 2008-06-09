From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 0/4] Python scripts for analyzing NFS/RPC metrics
Date: Mon, 09 Jun 2008 13:11:24 -0400
Message-ID: <RTPCLUEXC1-PRDVIdGs000001d6@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080609163029.5461.35699.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860AbYFIRLu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 13:11:50 -0400
In-Reply-To: <20080609163029.5461.35699.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
References: <20080609163029.5461.35699.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way. I love these scripts. The best thing about them is the
way they actually analyze the realtime performance of each RPC
procedure and server mount point including latencies and queuing,
which are nearly impossible to figure out with the commandline.
For example, they instantly tell whether the RPC slot table is too
small (or large) for the workload.

Tom.

At 12:47 PM 6/9/2008, Chuck Lever wrote:
>Hi Steve-
>
>As promised, here are the Python scripts that I've implemented for analyzing
>NFS and RPC performance metrics reported via /proc/self/mountstats.  They
>still need man pages and proper installation in the nfs-utils Makefile.
>
>While we decide whether to install and support these scripts as they are, or
>to replace them with C language re-implementations, let's include them in
>nfs-utils now so folks can try them out, bugs can be addressed, and missing
>features provided.
>
>---
>
>Chuck Lever (2):
>      Import the old iostat-ms Python script
>      Import mountstats utility
>
>Tom Talpey (2):
>      NFS iostats - add RDMA statistics
>      NFS mountstats - add RDMA statistics
>
>
> tools/mountstats/mountstats.py |  604 ++++++++++++++++++++++++++++++++++++++++
> tools/nfs-iostat/nfs-iostat.py |  564 +++++++++++++++++++++++++++++++++++++
> 2 files changed, 1168 insertions(+), 0 deletions(-)
> create mode 100755 tools/mountstats/mountstats.py
> create mode 100755 tools/nfs-iostat/nfs-iostat.py
>
>-- 
>Chuck Lever
>chuck[dot]lever[at]oracle[dot]com
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

