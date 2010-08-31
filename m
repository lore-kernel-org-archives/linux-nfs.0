Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57129 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752246Ab0HaQ1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 12:27:16 -0400
Date: Tue, 31 Aug 2010 12:26:48 -0400
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Marc Eshel <eshel@almaden.ibm.com>,
        linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Subject: Re: Linux pNFS status meeting 08/26
Message-ID: <20100831162648.GF3071@fieldses.org>
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com>
 <OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com>
 <OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com>
 <4C761A61.2070203@panasas.com>
 <273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 02:15:43PM -0700, Labiaga, Ricardo wrote:
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
> For the 1st wave of functionality, the suggestion is to submit three
> large patches:
> 
> 1. Everything that touches NFS common code 
>   (such as init and uninit pNFS, pnfs_update_layout invocations)
> 2. Layoutget and getdeviceinfo generic code common to all layout drivers
> 3. File layout specific layoutget and getdeviceinfo

I understand large patches for the latter two, but for the first, might
it be worth keeping smaller patches?  Changes to common code seem most
at risk of breaking existing functionality.  And they might be
individually testable (since you can test for regressions), as opposed to
the new stuff that may be impossible to test until it's all applied.

But that's all just generalities--if people who've looked at the patches
don't think they split up sensibly, then fine.

--b.
