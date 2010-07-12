From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] nfs41_sequence_done
Date: Mon, 12 Jul 2010 21:58:44 +0300
Message-ID: <4C3B65E4.4070704@panasas.com>
References: <20100712182927.GB22461@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59924 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756375Ab0GLS6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:58:51 -0400
In-Reply-To: <20100712182927.GB22461-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[pnfs@linux-nfs.org -> linux-nfs@vger.kernel.org]

On Jul. 12, 2010, 21:29 +0300, Jim Rees <rees@umich.edu> wrote:
> Does anyone still care about this?
> 
>  WARNING: nfs41_sequence_done: Operation in progress slot=1 seq=7 highest_used_slotid=1: please report to pnfs@linux-nfs.org if you saw this message

Heh, need to update hard-coded instructions to point to the new list...

> 
> I'm getting this on the client side of a pnfs block layout mount against the
> spnfs server.  Kernel is benny's pnfs-all-2.6.35-rc3-2010-07-01 plus EMC
> complex block layout patches.  It's possible the complex layout code is to
> blame, but I doubt it because this isn't a complex layout mount.  I can
> provide more details.

I agree.  This is a generic issue.
The patch that  adds this check is
d6ce9ad DEVONLY: nfs41: Do not free slot if retried while operation was in progress

It was originally rejected (http://www.spinics.net/lists/linux-nfs/msg09562.html)
due to noise regarding where nfs41_sequence_free_slot is called
but that masked the real issue.

Can you readily reproduce this?
Can you debug also the server side to see if indeed the client retries the RPC
while it is in progress on the server?

Benny

> _______________________________________________
> NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org
> instead.  (To subscribe to linux-nfs@vger.kernel.org: send "subscribe
> linux-nfs" in the body of a message to majordomo-u79uwXL29TaiAVqoAR/hOA@public.gmane.org)
> 
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
