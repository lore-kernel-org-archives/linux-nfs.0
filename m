Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:57079 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982AbaFBV7N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 17:59:13 -0400
Message-ID: <538CF346.2070504@zytor.com>
Date: Mon, 02 Jun 2014 14:57:26 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Arnd Bergmann <arnd@arndb.de>
CC: "Joseph S. Myers" <joseph@codesourcery.com>, linux-kernel@vger.kernel.org,
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
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <4233989.Saca0ocOUr@wuerfel> <538CCFDE.2010107@zytor.com> <7175692.dpgYFMbTaP@wuerfel>
In-Reply-To: <7175692.dpgYFMbTaP@wuerfel>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/02/2014 12:55 PM, Arnd Bergmann wrote:
>>
>> The bit that is really going to hurt is every single ioctl that uses a
>> timespec.
>>
>> Honestly, though, I really don't understand the point with "struct
>> inode_time".  It seems like the zeroeth-order thing is to change the
>> kernel internal version of struct timespec to have a 64-bit time... it
>> isn't just about inodes.  We then should be explicit about the external
>> uses of time, and use accessors.
> 
> I picked these because they are fairly isolated from all other uses,
> in particular since inode times are the only things where we really
> care about times in the distant past or future (decades away as opposed
> to things that happened between boot and shutdown).
> 

If nothing else, I would expect to be able to set the system time to
weird values for testing.  So I'm not so sure I agree with that...

> For other kernel-internal uses, we may be better off migrating to
> a completely different representation, such as nanoseconds since
> boot or the architecture specific ktime_t, but this is really something
> to decide for each subsystem.

Having a bunch of different time representations in the kernel seems
like a real headache...

	-hpa


