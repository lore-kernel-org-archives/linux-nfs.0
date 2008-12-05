From: Neil Brown <neilb@suse.de>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Fri, 5 Dec 2008 17:05:57 +1100
Message-ID: <18744.50373.912982.580991@notabene.brown>
References: <200811281541.39272.t.bubeck@reinform.de>
	<200812041025.02563.t.bubeck@reinform.de>
	<4937E243.1080608@RedHat.com>
	<200812041516.14114.t.bubeck@reinform.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39123 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808AbYLEGFz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 01:05:55 -0500
In-Reply-To: message from Dr. Tilmann Bubeck on Thursday December 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday December 4, t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org wrote:
> It's very good that it is fixed in Fedora (my preferred distribution), but it 
> is still wrong in SuSe (verified) and probably more.

Could you be more specific about SuSe please?  I just checked 11.1,
11.0, 10.3, SLES10sp2 and SLES9sp4 and they all look like they have it
in the right order.

> 
> A better way would be to fix NFS and its utilities itself instead of fixing 
> the distribution. This means, that the way the kernel and nfs-utils interact 
> should be made more robust (see my posting before).

Each distro has the its own init scripts.  The best that we as upstream
can do is document what is required.
The fact that "mount -t nfsd /proc/fs/nfsd" should be first on the
server is very clear from the README file distributed with nfs-utils.

Can you be more precise about what you suggest could be fixed in NFS
and its utilities?

You said in the original email:

> Questions: is this behaviour a bug or at least bad? Shouldn't exportfs being 
> changed, so that when it detects "new" mode it will never feed rmtab into the 
> kernel and rely upon rpc.mountd answering the kernels questions as stated 
> in "man exportfs"?

I believe that when exportfs detects "new" mode it will never feed
rmtab into the kernel.  So there is nothing to be fixed there.

Confused?

Thanks,
NeilBrown

