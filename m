Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:57265 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbaFAEqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Jun 2014 00:46:44 -0400
Date: Sun, 1 Jun 2014 06:46:09 +0200
From: Richard Cochran <richardcochran@gmail.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
        hch@infradead.org, linux-mtd@lists.infradead.org, logfs@logfs.org,
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
Message-ID: <20140601044609.GD3722@localhost.localdomain>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <20140531145114.GA3721@localhost.localdomain>
 <6347520.8jMPlVsFjM@wuerfel>
 <20140531182237.GA5382@localhost.localdomain>
 <57071155-5a08-4579-9189-92d442cd65e7@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <57071155-5a08-4579-9189-92d442cd65e7@email.android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 31, 2014 at 12:34:12PM -0700, H. Peter Anvin wrote:
> Typically they are using 64-bit signed seconds.

Okay, that is what I wanted to know.

Thanks,
Richard
