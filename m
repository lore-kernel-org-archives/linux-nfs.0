Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36029 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaFAEpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Jun 2014 00:45:14 -0400
Date: Sun, 1 Jun 2014 06:44:36 +0200
From: Richard Cochran <richardcochran@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, hch@infradead.org,
        linux-mtd@lists.infradead.org, hpa@zytor.com, logfs@logfs.org,
        linux-afs@lists.infradead.org, joseph@codesourcery.com,
        linux-arch@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-scsi@vger.kernel.org, ceph-devel@vger.kernel.org,
        codalist@TELEMANN.coda.cs.cmu.edu, cluster-devel@redhat.com,
        coda@cs.cmu.edu, geert@linux-m68k.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, john.stultz@linaro.org, tglx@linutronix.de,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        samba-technical@lists.samba.org,
        linux-f2fs-devel@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, lftan@altera.com,
        linux-btrfs@vger.kernel.org
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Message-ID: <20140601044436.GC3722@localhost.localdomain>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <20140531145114.GA3721@localhost.localdomain>
 <6347520.8jMPlVsFjM@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6347520.8jMPlVsFjM@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 31, 2014 at 05:23:02PM +0200, Arnd Bergmann wrote:
> On Saturday 31 May 2014 16:51:15 Richard Cochran wrote:
> > 
> > Why are some of the time stamp expiration dates marked as "never"?
> 
> It's an approximation:

Also, the term "never" might mean using arbitrarily long integers
as in ASN.1.

Thanks,
Richard
