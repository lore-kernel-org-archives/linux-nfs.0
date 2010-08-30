Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25267 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192Ab0H3VQH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 17:16:07 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Linux pNFS status meeting 08/26
Date: Mon, 30 Aug 2010 14:15:43 -0700
Message-ID: <273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <4C761A61.2070203@panasas.com>
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com><OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com><OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com> <4C761A61.2070203@panasas.com>
From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
To: "Benny Halevy" <bhalevy@panasas.com>, "Marc Eshel" <eshel@almaden.ibm.com>
Cc: <linux-nfs@vger.kernel.org>, <nfsv4@linux-nfs.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Last week Andy, Fred, Trond, and I were physically in the same location,
so we took the opportunity to review the first set of patches in the
pnfs-submit branch and further discussed the best way to proceed with
the submission.  For ease of review, Trond reiterated that we submit our
patches in waves of functionality and that they be submitted as a set of
few large patches.

The proposal is to submit the functionality in the following order:

1st Layoutget and getdeviceinfo (together)
2nd Layoutreturn
3rd Read/ Write I/O path (could be broken into two sets)
4th Callback Path
5th Layoutcommit

For the 1st wave of functionality, the suggestion is to submit three
large patches:

1. Everything that touches NFS common code 
  (such as init and uninit pNFS, pnfs_update_layout invocations)
2. Layoutget and getdeviceinfo generic code common to all layout drivers
3. File layout specific layoutget and getdeviceinfo

This means we have about 19 or so of the first pnfs-submit patches that
need to be squashed into a single patch for ease of review.  In
addition, we found a number of minor issues during the review that need
to be addressed.  We also need to strip out some things that are not
strictly needed for the first wave of patches, with the intent to
reintroduce them when the functionality is actually used by objects and
blocks.  It was made clear that including functionality that is not
required by the File Layout driver at this time is not appropriate.  For
example, io_ops that are no required by the File Layout (and have a
trivial implementation) are a no-go.  The abstraction is best introduced
when the drivers that actually require it are submitted.

Andy and Fred will email the details of the changes along with the
patches shortly.

Net-net, no radical changes needed, but a number of small issues that
need to be addressed before we can start submitting.  More details
coming shortly.

Thanks,
	
- ricardo


> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@panasas.com]
> Sent: Thursday, August 26, 2010 12:40 AM
> To: Marc Eshel
> Cc: linux-nfs@vger.kernel.org; nfsv4@linux-nfs.org
> Subject: Re: Linux pNFS status meeting 08/26
> 
> On Aug. 26, 2010, 6:32 +0300, Marc Eshel <eshel@almaden.ibm.com>
wrote:
> > Meeting on Thursday 08/26/10 at 9:30 AM pacific time (12:30 PM UMICH
> time)
> 
> Sorry, I can't make it today.
> Latest status: pnfs-all-2.6.35-2010-08-24 was released with
> the latest pnfs-submit branch, including Andy's renaming work
> and his fix of a rcu bug in pnfs deviceid cache found by Fred.
> 
> I applied the renames onto the rest of the generic pnfs code and
> layout drivers as well as renamed code for the callback path
> to match the existing naming convention. I also cleaned up
> the patchset itself to get it one step closer for the next step.
> 
> Right now I'm rebasing the tree onto 2.6.36-rc1 and will release
> the rebased version after giving it a good test.
> 
> The next step is reorganize the patchset into shorter runs and
> possibly squash together some small patches into bigger ones as
> we discussed so to make it easier for review.
> 
> Benny
> 
> >
> > Marc.
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> _______________________________________________
> NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org
> instead.
> (To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs"
> in the body of a message to majordomo@vger.kernel.org.)
> 
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
