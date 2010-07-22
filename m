Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55870 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944Ab0GVKfE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 06:35:04 -0400
Date: Thu, 22 Jul 2010 12:35:03 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: David Howells <dhowells@redhat.com>
cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 file stats available [ver #6]
In-Reply-To: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
Message-ID: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Thursday 2010-07-15 04:17, David Howells wrote:
> (6) BSD stat compatibility: Including more fields from the BSD stat such as
>     creation time (st_btime) and inode generation number (st_gen) [Jeremy
>     Allison, Bernd Schubert].
>where st_btime is the file creation time, st_gen is the inode generation
>(i_generation), st_data_version is the data version number (i_version),
>st_inode_flags is the flags from FS_IOC_GETFLAGS plus some extras,
>request_mask and st_result_mask are bitmasks of data desired/provided and
>st_extra_results[] is where as-yet undefined fields are appended.

Linux already has a creation time field, it's called otime (there is no "b" in
"creation"), and you will find scattered fragments of that all over the kernel
(foremost, fs/jfs/, now btrfs, and I also notice sysvipc having something with
that name).

>	struct xstat_time {
>		unsigned long long	tv_sec, tv_nsec;
>	};

If it helps getting rid of the ugly suseconds_t in userspace ;-)
