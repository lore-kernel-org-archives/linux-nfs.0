From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/4] Support "-t nfs,vers=4" mounts in the kernel [take
 4]
Date: Mon, 14 Sep 2009 14:28:01 -0400
Message-ID: <1252952881.6866.64.camel@heimdal.trondhjem.org>
References: <20090902135032.3550.23170.stgit@matisse.1015granger.net>
	 <4AA6A7B5.1060301@RedHat.com>
	 <1252517471.8722.19.camel@heimdal.trondhjem.org>
	 <4AAE88B8.90908@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28565 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756769AbZINS2a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 14:28:30 -0400
In-Reply-To: <4AAE88B8.90908-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-09-14 at 14:17 -0400, Steve Dickson wrote:
> On 09/09/2009 01:31 PM, Trond Myklebust wrote:
> > On Tue, 2009-09-08 at 14:51 -0400, Steve Dickson wrote:
> >> On 09/02/2009 09:51 AM, Chuck Lever wrote:
> >>> Sorry for the repost.  After reading the patch descriptions again, I
> >>> thought they needed some clarification.
> >>>
> >>> ---
> >>>
> >>> Chuck Lever (4):
> >>>       NFS: Allow the "nfs" file system type to support NFSv4
> >>>       NFS: Move details of nfs4_get_sb() to a helper
> >>>       NFS: Refactor NFSv4 text-based mount option validation
> >>>       NFS: Mount option parser should detect missing "port="
> >>>
> >>>
> >>>  fs/nfs/internal.h    |   10 ++
> >>>  fs/nfs/super.c       |  202 +++++++++++++++++++++++++++++++++-----------------
> >>>  include/linux/nfs4.h |    1 These patches (after a bit of back porting) are now in the F-12 and Rawhide 
> kernels, 
> >>>  3 files changed, 144 insertions(+), 69 deletions(-)
> >>>
> >> Trond,
> >>
> >> I'm updating the mount.nfs man pages, and would like give 
> >> an guess-ta-mate as to which kernel these patches will be in.
> >> Any ideas?
> > 
> > I'm planning on pushing them out in the upcoming merge window, since the
> > patches themselves seem pretty straightforward. I've applied the fixes
> > that I suggested, and added the patch to disable vers!=4 in the '-t
> > nfs4' case.
> > 
> > If you'd like to test it all out, I've pushed those patches into the
> > nfs-for-2.6.32 branch of my git tree. They should also appear in
> > linux-next.
> After a weekend of testing these patches along with Chunk's mount.nfs 
> patches, I committed these patches (after some back porting) to both 
> the Fedora F-12 and Rawhide kernels, which means they will get plenty 
> of testing by the time 2.6.32 rolls around...

Thanks! I've already pushed them upstream to Linus.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
