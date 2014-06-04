Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.126.131]:55366 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbaFDPG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 11:06:27 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "Joseph S. Myers" <joseph@codesourcery.com>
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Date: Wed, 4 Jun 2014 17:05:27 +0200
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        john.stultz@linaro.org, hch@infradead.org, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com, hpa@zytor.com,
        linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, coda@cs.cmu.edu,
        codalist@TELEMANN.coda.cs.cmu.edu, fuse-devel@lists.sourceforge.net,
        linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-scsi@vger.kernel.org, logfs@logfs.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        samba-technical@lists.samba.org, xfs@oss.sgi.com
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <4233989.Saca0ocOUr@wuerfel> <Pine.LNX.4.64.1406022044090.27099@digraph.polyomino.org.uk>
In-Reply-To: <Pine.LNX.4.64.1406022044090.27099@digraph.polyomino.org.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201406041705.27599.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 02 June 2014, Joseph S. Myers wrote:
> On Mon, 2 Jun 2014, Arnd Bergmann wrote:
> 
> > Ok. Sorry about missing linux-api, I confused it with linux-arch, which
> > may not be as relevant here, except for the one question whether we
> > actually want to have the new ABI on all 32-bit architectures or only
> > as an opt-in for those that expect to stay around for another 24 years.
> 
> For glibc I think it will make the most sense to add the support for 
> 64-bit time_t across all architectures that currently have 32-bit time_t 
> (with the new interfaces having fallback support to implementation in 
> terms of the 32-bit kernel interfaces, if the 64-bit syscalls are 
> unavailable either at runtime or in the kernel headers against which glibc 
> is compiled - this fallback code will of course need to check for overflow 
> when passing a time value to the kernel, hopefully with error handling 
> consistent with whatever the kernel ends up doing when a filesystem can't 
> support a timestamp).  If some architectures don't provide the new 
> interfaces in the kernel then that will mean the fallback code in glibc 
> can't be removed until glibc support for those architectures is removed 
> (as opposed to removing it when glibc no longer supports kernels predating 
> the kernel support).

Ok, that's a good reason to just provide the new interfaces on all
architectures right away. Thanks for the insight!

	Arnd
