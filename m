Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy4-pub.mail.unifiedlayer.com ([69.89.23.142]:49060 "HELO
	gproxy4-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756752AbaEaObO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 May 2014 10:31:14 -0400
Message-ID: <1401546649.2413.6.camel@slavad-CELSIUS-H720>
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org, hch@infradead.org,
        tglx@linutronix.de, geert@linux-m68k.org, lftan@altera.com,
        hpa@zytor.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, cluster-devel@redhat.com, coda@cs.cmu.edu,
        codalist@TELEMANN.coda.cs.cmu.edu, fuse-devel@lists.sourceforge.net,
        linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-scsi@vger.kernel.org, logfs@logfs.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        samba-technical@lists.samba.org, xfs@oss.sgi.com
Date: Sat, 31 May 2014 18:30:49 +0400
In-Reply-To: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Arnd,

On Fri, 2014-05-30 at 22:01 +0200, Arnd Bergmann wrote:

[snip]
> 
> Arnd Bergmann (32):
>   fs: introduce new 'struct inode_time'
>   uapi: add struct __kernel_timespec{32,64}
>   fs: introduce sys_utimens64at
>   fs: introduce sys_newfstat64/sys_newfstatat64
>   arch: hook up new stat and utimes syscalls
>   isofs: fix timestamps beyond 2027
>   fs/nfs: convert to struct inode_time
>   fs/ceph: convert to 'struct inode_time'
>   fs/pstore: convert to struct inode_time
>   fs/coda: convert to struct inode_time
>   xfs: convert to struct inode_time
>   btrfs: convert to struct inode_time
>   ext3: convert to struct inode_time
>   ext4: convert to struct inode_time
>   cifs: convert to struct inode_time
>   ntfs: convert to struct inode_time
>   ubifs: convert to struct inode_time
>   ocfs2: convert to struct inode_time
>   fs/fat: convert to struct inode_time
>   afs: convert to struct inode_time
>   udf: convert to struct inode_time
>   fs: convert simple fs to inode_time
>   logfs: convert to struct inode_time
>   hfs, hfsplus: convert to struct inode_time
>   gfs2: convert to struct inode_time
>   reiserfs: convert to struct inode_time
>   jffs2: convert to struct inode_time
>   adfs: convert to struct inode_time
>   f2fs: convert to struct inode_time
>   fuse: convert to struct inode_time
>   scsi: fnic: use current_kernel_time() for timestamp
>   fs: use new inode_time definition unconditionally
> 

By the way, what about NILFS2? Is NILFS2 ready for suggested approach
without any changes?

Thanks,
Vyacheslav Dubeyko.


