From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 11:42:54 +1000
Message-ID: <48D1B21E.3060509@melbourne.sgi.com>
References: <997439.5560.qm@web32601.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:58808 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753149AbYIRBo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 21:44:29 -0400
In-Reply-To: <997439.5560.qm-VAEUvbQToQWvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Martin Knoblauch wrote:
> Hi,
>
> the following/attached patch works around a [obscure] problem when an 2.6 (not sure/caring about 2.4) NFS client accesses an "offline" file on a Sun/Solaris-10 NFS server when the underlying filesystem is of type SAM-FS. Happens with RHEL4/5 and mainline kernels. Frankly, it is not a Linux problem, but the chance for a short-/mid-term solution from Sun are very slim. So, being lazy, I would love to get this patch into Linux. If not, I just will have to maintain it for eternity out of tree.
>
> The problem: SAM-FS is Suns proprietary HSM filesystem. It stores meta-data and a relatively small amount of data "online" on disk and pushes old or infrequently used data to "offline" media like e.g. tape. This is completely transparent to the users. If the date for an "offline" file is needed, the so called "stager daemon" copies it back from the offline medium. All of this works great most of the time. Now, if an Linux NFS client tries to read such an offline file, performance drops to "extremely slow". 
By "extremely slow" do you mean "tape read speed"?
> After lengthly investigation of tcp-dumps, mount options and procedures involving black cats at midnight, we found out that the readahead behaviour of the Linux NFS client causes the problem. Basically it seems to issue read requests up to 15*rsize to the server. In the case of the "offline" files, this behaviour causes heavy competition for the inode lock between the NFSD process and the stager daemon on the Solaris server.
>   
So, you need to

a) make your stager daemon do IO more sensibly, and

b) apply something like this patch which adds O_NONBLOCK when knfsd does
reads writes and truncates and translates -EAGAIN into NFS3ERR_JUKEBOX

http://kerneltrap.org/mailarchive/linux-fsdevel/2006/5/5/312567

and

c) make your filesystem IO interposing layer report -EAGAIN when a
process tries to do IO to an offline region in a file and O_NONBLOCK is
present.
> - The real solution: fixing SAM-FS/NFSD interaction. Sun engineering acks the problem, but a solution will need time. Lots of it.
> - The working solution: disable the client side readahead, or make it tunable. The patch does that by introducing a NFS module parameter "ra_factor" which can take values between 1 and 15 (default 15) and a tunable "/proc/sys/fs/nfs/nfs_ra_factor" with the same range and default.
>   
I think having a tunable for client readahead is an excellent idea,
although not to solve your particular problem.  The SLES10 kernel has a
patch which does precisely that, perhaps Neil could post it.

I don't think there's a lot of point having both a module parameter and
a sysctl.

A maximum of 15 is unwise.  I've found that (at least with the older
readahead mechanisms in SLES10) a multiple of 4 is required to preserve
rsize-alignment of READ rpcs to the server, which helps a lot with wide
RAID backends.  So in SGI we tune client readahead to 16.

Your patch seems to have a bunch of other unrelated stuff mixed in.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
Be like the squirrel.
I don't speak for SGI.

