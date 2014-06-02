Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay1.mentorg.com ([192.94.38.131]:43565 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbaFBVCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 17:02:34 -0400
Date: Mon, 2 Jun 2014 21:02:15 +0000
From: "Joseph S. Myers" <joseph@codesourcery.com>
To: Arnd Bergmann <arnd@arndb.de>
CC: <linux-kernel@vger.kernel.org>, <linux-arch@vger.kernel.org>,
        <john.stultz@linaro.org>, <hch@infradead.org>, <tglx@linutronix.de>,
        <geert@linux-m68k.org>, <lftan@altera.com>, <hpa@zytor.com>,
        <linux-fsdevel@vger.kernel.org>, <ceph-devel@vger.kernel.org>,
        <cluster-devel@redhat.com>, <coda@cs.cmu.edu>,
        <codalist@TELEMANN.coda.cs.cmu.edu>,
        <fuse-devel@lists.sourceforge.net>, <linux-afs@lists.infradead.org>,
        <linux-btrfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
        <linux-ext4@vger.kernel.org>, <linux-f2fs-devel@lists.sourceforge.net>,
        <linux-mtd@lists.infradead.org>, <linux-nfs@vger.kernel.org>,
        <linux-ntfs-dev@lists.sourceforge.net>, <linux-scsi@vger.kernel.org>,
        <logfs@logfs.org>, <ocfs2-devel@oss.oracle.com>,
        <reiserfs-devel@vger.kernel.org>, <samba-technical@lists.samba.org>,
        <xfs@oss.sgi.com>
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
In-Reply-To: <4233989.Saca0ocOUr@wuerfel>
Message-ID: <Pine.LNX.4.64.1406022044090.27099@digraph.polyomino.org.uk>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <Pine.LNX.4.64.1406021350030.19591@digraph.polyomino.org.uk>
 <4233989.Saca0ocOUr@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Jun 2014, Arnd Bergmann wrote:

> Ok. Sorry about missing linux-api, I confused it with linux-arch, which
> may not be as relevant here, except for the one question whether we
> actually want to have the new ABI on all 32-bit architectures or only
> as an opt-in for those that expect to stay around for another 24 years.

For glibc I think it will make the most sense to add the support for 
64-bit time_t across all architectures that currently have 32-bit time_t 
(with the new interfaces having fallback support to implementation in 
terms of the 32-bit kernel interfaces, if the 64-bit syscalls are 
unavailable either at runtime or in the kernel headers against which glibc 
is compiled - this fallback code will of course need to check for overflow 
when passing a time value to the kernel, hopefully with error handling 
consistent with whatever the kernel ends up doing when a filesystem can't 
support a timestamp).  If some architectures don't provide the new 
interfaces in the kernel then that will mean the fallback code in glibc 
can't be removed until glibc support for those architectures is removed 
(as opposed to removing it when glibc no longer supports kernels predating 
the kernel support).

> Two more questions for you:
> 
> - are you (and others) happy with adding this type of stat syscall
>   (fstatat64/fstat64) as opposed to the more generic xstat that has
>   been discussed in the past and that never made it through the bike-
>   shedding discussion?

I am.

> - once we have enough buy-in from reviewers to merge this initial
>   series, should we proceed to define rest of the syscall ABI
>   (minus driver ioctls) so glibc and kernel can do the conversion
>   on top of that, or should we better try to do things one syscall
>   family at a time and actually get the kernel to handle them
>   correctly internally?

I don't have any comments on that ordering question.

-- 
Joseph S. Myers
joseph@codesourcery.com
