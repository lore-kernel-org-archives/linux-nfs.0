Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.126.131]:52444 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbaFBTUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 15:20:54 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "Joseph S. Myers" <joseph@codesourcery.com>
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
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Date: Mon, 02 Jun 2014 21:19:55 +0200
Message-ID: <4233989.Saca0ocOUr@wuerfel>
In-Reply-To: <Pine.LNX.4.64.1406021350030.19591@digraph.polyomino.org.uk>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <Pine.LNX.4.64.1406021350030.19591@digraph.polyomino.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 02 June 2014 13:52:19 Joseph S. Myers wrote:
> On Fri, 30 May 2014, Arnd Bergmann wrote:
> 
> > a) is this the right approach in general? The previous discussion
> >    pointed this way, but there may be other opinions.
> 
> The syscall changes seem like the sort of thing I'd expect, although 
> patches adding new syscalls or otherwise affecting the kernel/userspace 
> interface (as opposed to those relating to an individual filesystem) 
> should go to linux-api as well as other relevant lists.

Ok. Sorry about missing linux-api, I confused it with linux-arch, which
may not be as relevant here, except for the one question whether we
actually want to have the new ABI on all 32-bit architectures or only
as an opt-in for those that expect to stay around for another 24 years.

Two more questions for you:

- are you (and others) happy with adding this type of stat syscall
  (fstatat64/fstat64) as opposed to the more generic xstat that has
  been discussed in the past and that never made it through the bike-
  shedding discussion?

- once we have enough buy-in from reviewers to merge this initial
  series, should we proceed to define rest of the syscall ABI
  (minus driver ioctls) so glibc and kernel can do the conversion
  on top of that, or should we better try to do things one syscall
  family at a time and actually get the kernel to handle them
  correctly internally?

	Arnd
