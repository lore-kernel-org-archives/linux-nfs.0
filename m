Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-out.m-online.net ([212.18.0.10]:34217 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab3KLSpE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 13:45:04 -0500
From: Andreas Schwab <schwab@linux-m68k.org>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, libc-alpha@sourceware.org,
        linux-api@vger.kernel.org, andreas.gruenbacher@gmail.com,
        samba-technical@lists.samba.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] statxat: Add a system call to make extended file stats available
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk>
	<20131112173534.25813.70732.stgit@warthog.procyon.org.uk>
Date: Tue, 12 Nov 2013 19:44:59 +0100
In-Reply-To: <20131112173534.25813.70732.stgit@warthog.procyon.org.uk> (David
	Howells's message of "Tue, 12 Nov 2013 17:35:34 +0000")
Message-ID: <87li0t31ec.fsf@igel.home>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> 	struct statx {
> 		uint32_t		st_mask;
> 		uint32_t		st_information;
> 		uint16_t		st_mode;
> 		uint16_t		__spare0[1];
> 		uint32_t		st_nlink;
> 		uint32_t		st_uid;
> 		uint32_t		st_gid;
> 		uint32_t		st_alloc_blksize;
> 		uint32_t		st_blksize;
> 		uint32_t		st_small_io_size;
> 		uint32_t		st_large_io_size;
> 		struct statx_dev	st_rdev;
> 		struct statx_dev	st_dev;
> 		int32_t			st_atime_ns;
> 		int32_t			st_btime_ns;
> 		int32_t			st_ctime_ns;
> 		int32_t			st_mtime_ns;
> 		int64_t			st_atime;
> 		int64_t			st_btime;
> 		int64_t			st_ctime;
> 		int64_t			st_mtime;
> 		uint64_t		st_ino;
> 		uint64_t		st_size;
> 		uint64_t		st_blocks;
> 		uint64_t		st_version;
> 		uint64_t		st_ioc_flags;

I'd suggest to use a different prefix (stx_ instead of st_) for the
members.  st_[acm]time are typically defined as macros by <sys/stat.h>
which would conflict.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
