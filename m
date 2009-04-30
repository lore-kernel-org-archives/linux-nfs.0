Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46566 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbZD3UMV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 16:12:21 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3UK6eWX016143
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2009 14:06:40 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3UKCLR3153836
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2009 14:12:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3UKCKh6022482
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2009 14:12:20 -0600
Received: from d03nm118.boulder.ibm.com (d03nm118.boulder.ibm.com [9.17.195.144])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n3UKCKrA022474
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2009 14:12:20 -0600
To: linux-nfs@vger.kernel.org
Subject: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
Date: Thu, 30 Apr 2009 16:12:19 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello all,

This is my first post, so please be gentle.... I have been working with a 
customer who is attempting to build their product in ClearCase dynamic 
views on Linux. When they went from Red hat Enterprise Linux 4 (update 5) 
to Red Hat Enterprise Linux 5 (Update 2), their build performance degraded 
dramatically. When troubleshooting the issue, we noticed that links on 
RHEL 5 caused an incredible number of "STABLE" 4kb nfs writes even though 
the storage we were writing to was EXPLICITLY mounted async. (This made 
RHEL 5 nearly 5x slower than RHEL 4.5 in this area...)

On consultation with some internal resources, we found this change in the 
2.6 kernel:
        
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ab0a3dbedc51037f3d2e22ef67717a987b3d15e2

In here it looks like the NFS client is forcing sync writes any time a 
write of less than the NFS write size occurs. We tested this hypothesis by 
setting the write size to 2KB. The "STABLE" writes went away and link 
times came back down out of the stratosphere. We built a modified kernel 
based on the RHEL 5.2 kernel (that ONLY backed out of this change) and we 
got a 33% improvement in overall build speeds. In my case, I see almost 
identical build times between the 2 OS's when we use this modified kernel 
on RHEL 5.

Now, why am I posing this to the list? I need to understand *why* that 
change was made. On the face of it, simply backing out that patch would be 
perfect. I'm paranoid. I want to make sure that this is the ONLY reason:
"/* For single writes, FLUSH_STABLE is more efficient */ "

It seems more accurate to say that they *aren't* more efficient, but 
rather are "safer, but slower."

I know that this is a 3+ year old update, but RHEL 4 is based on a 2.4 
kernel, and SLES 9 is based on something in the same ballpark. And our 
customers see problems when they go to SLES 10/RHEL 5 from the prior major 
distro version.

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.
