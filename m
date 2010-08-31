Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57271 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754032Ab0HaQ6K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 12:58:10 -0400
Message-ID: <4C7D349E.5010709@panasas.com>
Date: Tue, 31 Aug 2010 19:58:06 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, Marc Eshel <eshel@almaden.ibm.com>,
        linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Subject: Re: Linux pNFS status meeting 08/26
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com><OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com><OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com> <4C761A61.2070203@panasas.com> <273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/31/2010 12:15 AM, Labiaga, Ricardo wrote:
> Last week Andy, Fred, Trond, and I were physically in the same location,
> so we took the opportunity to review the first set of patches in the
> pnfs-submit branch and further discussed the best way to proceed with
> the submission.  For ease of review, Trond reiterated that we submit our
> patches in waves of functionality and that they be submitted as a set of
> few large patches.
> 
> The proposal is to submit the functionality in the following order:
> 
> 1st Layoutget and getdeviceinfo (together)
> 2nd Layoutreturn
> 3rd Read/ Write I/O path (could be broken into two sets)
> 4th Callback Path
> 5th Layoutcommit
> 

A natural read and understanding of pnfs has this logical progression

1st Layoutget and getdeviceinfo (together)
2rd Read/ Write I/O path (could be broken into two sets)
3rd Layoutcommit
4th Layoutreturn
5th Callback Path

Could you elaborate a bit on why you choose to reorder them this way?

> For the 1st wave of functionality, the suggestion is to submit three
> large patches:
> 

I would love to see a:
0. Complete STD definitions headers

> 1. Everything that touches NFS common code 
>   (such as init and uninit pNFS, pnfs_update_layout invocations)

Separation to proc and XDR layers

> 2. Layoutget and getdeviceinfo generic code common to all layout drivers

Is that the high level pnfs.c stuff? then YES nice.

Will this be together with it's invocation at the nfs-vfs files like
inode.c write.c etc.. ?

> 3. File layout specific layoutget and getdeviceinfo
> 

You might want to reorder 2 and 3. First submit services which are at first
dead code. Then submit the code that calls them. Are you making a point
in making each patch compilable, runnable through out?

> This means we have about 19 or so of the first pnfs-submit patches that
> need to be squashed into a single patch for ease of review.  In
> addition, we found a number of minor issues during the review that need
> to be addressed.  We also need to strip out some things that are not
> strictly needed for the first wave of patches, with the intent to
> reintroduce them when the functionality is actually used by objects and
> blocks.  It was made clear that including functionality that is not
> required by the File Layout driver at this time is not appropriate.  For
> example, io_ops that are no required by the File Layout (and have a
> trivial implementation) are a no-go.  The abstraction is best introduced
> when the drivers that actually require it are submitted.
> 
> Andy and Fred will email the details of the changes along with the
> patches shortly.
> 
> Net-net, no radical changes needed, but a number of small issues that
> need to be addressed before we can start submitting.  More details
> coming shortly.
> 
> Thanks,
> 	
> - ricardo

Thanks
Boaz
