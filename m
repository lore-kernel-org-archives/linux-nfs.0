From: Neil Brown <neilb@suse.de>
Subject: Re: Doc for adding new NFS export option
Date: Wed, 9 Jul 2008 13:58:25 +1000
Message-ID: <18548.14177.493986.264761@notabene.brown>
References: <48718FF4.4030200@cse.unsw.edu.au>
	<18545.47041.516146.605353@notabene.brown>
	<4874263B.50902@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:57517 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160AbYGID6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 23:58:31 -0400
In-Reply-To: message from Shehjar Tikoo on Wednesday July 9
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday July 9, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
> Neil Brown wrote:
> > On Monday July 7, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
> >> Hi All
> >>
> >> Is there a document that enumerates which files and functions I need 
> >> to add stuff to, for adding a new server-side export option?
> > 
> > No.  I think the theory is that unless you have read and understood
> > the code, you should really be thinking about adding new options.
> > And if you have, then you don't need any documentations.
> > :-)
> > 
> >> I've tried adding it to some of the functions in the exportfs related 
> >> code in nfs-utils and also in the kernel's export related headers but 
> >> I dont think that is all there is to it.
> > 
> > That sounds good, but without details, it is hard to be sure.
> > Don't be afraid to send a patch which shows what you are trying to do.
> 
> See the two diffs attached here:
> 
> 1. nfs_utils_add_prealloc.diff
> Adds support for "prealloc" and "no_prealloc" export options to 
> nfs-utils. Based on the latest nfs-utils at:
> git://linux-nfs.org/nfs-utils
> 
> 2. add_nfsd_prealloc.diff
> Adds support to kernel for the two options above. Based on 2.6.25.10 
> git checkout from:
> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.25.y.git
> 
> The patches dont actually make nfsd do anything at this point because 
> to do any "prealloc" related work, I first need to be able to mount 
> the export with the new option. :)
> 
> >> I ask this because without my new option, I am able to mount the 
> >> export correctly but with it, the mount command fails with the 
> >> following message:
> >>
> >> mount.nfs: 192.168.10.5:/data/nfstest failed, reason given by server: 
> >> Permission denied
> The above behaviour was observed with nfs-utils 1.1.2.
> The strange thing is, for nfs-utils from the git repo, with the 
> patches above, mount command returns the same error regardless of 
> whether "prealloc" option is specified in /etc/exports.

You are restarting a newly compiled mountd I assume?  I cannot think
what else might cause the problem.

> 
> > 
> > So what exactly is this new export option that you want to add?
> 
> As the option's name suggests, the idea is to use fallocate support in 
> ext4 and XFS, to pre-allocate disk blocks. I feel this might help nfsd 
>   sync writes where each write request has to go to disk almost ASAP. 
> Because NFSv3 writes have to be stable(..not sure about NFSv4..), the 
> write-to-disk and block allocation must happen immediately. It is 
> possible that the blocks being allocated for each NFS sync write are 
> not as contiguous as they could be for say, local buffered writes.
> I am hoping that by using some form of adaptive pre-allocation we can 
> improve the contiguity of disk blocks for nfsd writes.
> 

NFSv3 writes do not have to be stable.  The client will usually
request DATA_UNSTABLE, and then send a COMMIT a while later.  This
should give the filesystem time to do delayed allocation.
NFSv4 is much the same.
NFSv2 does require stable writes, but it should not be used by anyone
interested in good write performance on large files.

It isn't clear to me that this is something that should be an option
in /etc/exports.
When would a sysadmin want to turn it off?  Or if a sysadmin did want
control, sure the level of control required would be the size of the
preallocation. 

I would strongly suggest demonstrating that you can improve some
measure of performance using preallocation before you even begin to
think about having an export option to select it.

NeilBrown
