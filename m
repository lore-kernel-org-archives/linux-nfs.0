Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:58410 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbaEaTgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 May 2014 15:36:53 -0400
In-Reply-To: <20140531182237.GA5382@localhost.localdomain>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <20140531145114.GA3721@localhost.localdomain> <6347520.8jMPlVsFjM@wuerfel> <20140531182237.GA5382@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Sat, 31 May 2014 12:34:12 -0700
To: Richard Cochran <richardcochran@gmail.com>, Arnd Bergmann <arnd@arndb.de>
CC: linux-kernel@vger.kernel.org, hch@infradead.org,
        linux-mtd@lists.infradead.org, logfs@logfs.org,
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
Message-ID: <57071155-5a08-4579-9189-92d442cd65e7@email.android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Typically they are using 64-bit signed seconds.

On May 31, 2014 11:22:37 AM PDT, Richard Cochran <richardcochran@gmail.com> wrote:
>On Sat, May 31, 2014 at 05:23:02PM +0200, Arnd Bergmann wrote:
>> 
>> It's an approximation:
>
>(Approximately never ;)
>
>> with 64-bit timestamps, you can represent close to 300 billion
>> years, which is way past the time that our planet can sustain
>> life of any form[1].
>
>Did you mean mean 64 bits worth of seconds?
>
>  2^64 / (3600*24*365) = 584,942,417,355
>
>That is more than 300 billion years, and still, it is not quite the
>same as "never".
>
>In any case, that term is not too helpful in the comparison table,
>IMHO. One could think that some sort of clever running count relative
>to the last mount time was implied.
>
>Thanks,
>Richard
>
>[1] You are forgetting the immortal robotic overlords.

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.
