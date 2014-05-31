Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.126.187]:57148 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaEaPXx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 May 2014 11:23:53 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Richard Cochran <richardcochran@gmail.com>
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
Date: Sat, 31 May 2014 17:23:02 +0200
Message-ID: <6347520.8jMPlVsFjM@wuerfel>
In-Reply-To: <20140531145114.GA3721@localhost.localdomain>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <20140531145114.GA3721@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday 31 May 2014 16:51:15 Richard Cochran wrote:
> On Fri, May 30, 2014 at 10:01:24PM +0200, Arnd Bergmann wrote:
> > 
> > I picked this because it is a fairly isolated problem, as the
> > inode time stamps are rarely assigned to any other time values.
> > As a byproduct of this work, I documented for each of the file
> > systems we support how long the on-disk format can work[1].
> 
> Why are some of the time stamp expiration dates marked as "never"?

It's an approximation:
with 64-bit timestamps, you can represent close to 300 billion
years, which is way past the time that our planet can sustain
life of any form[1].

	Arnd

[1] http://en.wikipedia.org/wiki/Timeline_of_the_far_future
