Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.17.13]:55621 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaFCOtb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 10:49:31 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "Joseph S. Myers" <joseph@codesourcery.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, john.stultz@linaro.org, hch@infradead.org,
        tglx@linutronix.de, geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, coda@cs.cmu.edu,
        codalist@telemann.coda.cs.cmu.edu, fuse-devel@lists.sourceforge.net,
        linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-scsi@vger.kernel.org, logfs@logfs.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        samba-technical@lists.samba.org, xfs@oss.sgi.com
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Date: Tue, 03 Jun 2014 16:37:46 +0200
Message-ID: <18158267.ZX0ZMPkVDT@wuerfel>
In-Reply-To: <Pine.LNX.4.64.1406031427130.12421@digraph.polyomino.org.uk>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <5011138.W0gbOc20Qp@wuerfel> <Pine.LNX.4.64.1406031427130.12421@digraph.polyomino.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 03 June 2014 14:33:10 Joseph S. Myers wrote:
> On Tue, 3 Jun 2014, Arnd Bergmann wrote:
> 
> > I think John Stultz and Thomas Gleixner have already started looking
> > at how the timekeeping code can be updated. Once that is done, we should
> > be able to add a functional 64-bit gettimeofday/settimeofday syscall
> > pair. While I definitely agree this is one of the most basic things to
> > have, it's also not an area of the kernel that is easy to change.
> 
> 64-bit clock_gettime / clock_settime instead of gettimeofday / 
> settimeofday should avoid the need for the kernel to have a 64-bit version 
> of struct timeval.  (Userspace 64-bit gettimeofday / settimeofday would 
> need to use a combination of the syscalls if the tz pointer is non-NULL.)

Yes, that's what I meant.

	Arnd
