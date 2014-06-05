Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:39895 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308AbaFEAOO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 20:14:14 -0400
Message-ID: <538FB570.8000502@zytor.com>
Date: Wed, 04 Jun 2014 17:10:24 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>
CC: Dave Chinner <david@fromorbit.com>, hch@infradead.org,
        linux-mtd@lists.infradead.org, logfs@logfs.org,
        linux-afs@lists.infradead.org,
        "Joseph S. Myers" <joseph@codesourcery.com>,
        linux-arch@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-scsi@vger.kernel.org, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, coda@cs.cmu.edu, geert@linux-m68k.org,
        linux-ext4@vger.kernel.org, codalist@telemann.coda.cs.cmu.edu,
        fuse-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, john.stultz@linaro.org, tglx@linutronix.de,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, lftan@altera.com,
        linux-btrfs@vger.kernel.org
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <201406041703.47592.arnd@arndb.de> <alpine.LFD.2.11.1406041308300.17310@knanqh.ubzr> <8770583.6XeZxCxOY8@wuerfel>
In-Reply-To: <8770583.6XeZxCxOY8@wuerfel>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/04/2014 12:24 PM, Arnd Bergmann wrote:
> 
> For other timekeeping stuff in the kernel, I agree that using some
> 64-bit representation (nanoseconds, 32/32 unsigned seconds/nanoseconds,
> ...) has advantages, that's exactly the point I was making earlier
> against simply extending the internal time_t/timespec to 64-bit
> seconds for everything.
> 

How much of a performance issue is it to make time_t 64 bits, and for
the bits there are, how hard are they to fix?

	-hpa


