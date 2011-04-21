From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH v2] nfs-utils: Increase the stdio file buffer size for
 procfs files
Date: Thu, 21 Apr 2011 08:28:40 -0400
Message-ID: <4DB022F8.4050706@RedHat.com>
References: <1302261406-9048-1-git-send-email-sean.finney@sonyericsson.com> <1302261406-9048-2-git-send-email-sean.finney@sonyericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Sean Finney <sean.finney@sonyericsson.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099Ab1DUM2n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Apr 2011 08:28:43 -0400
In-Reply-To: <1302261406-9048-2-git-send-email-sean.finney@sonyericsson.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/08/2011 07:16 AM, Sean Finney wrote:
> Previously, when writing to /proc/net/rpc/*/channel, if a cache line
> were larger than the default buffer size (likely 1024 bytes), mountd
> and svcgssd would split writes into a number of buffer-sized writes.
> Each of these writes would get an EINVAL error back from the kernel
> procfs handle (it expects line-oriented input and does not account for
> multiple/split writes), and no cache update would occur.
> 
> When such behavior occurs, NFS clients depending on mountd to finish
> the cache operation would block/hang, or receive EPERM, depending on
> the context of the operation.  This is likely to happen if a user is a
> member of a large (~100-200) number of groups.
> 
> Instead, every fopen() on the procfs files in question is followed by
> a call to setvbuf(), using a per-file dedicated buffer of
> RPC_CHAN_BUF_SIZE length.
> 
> Really, mountd should not be using stdio-style buffered file operations
> on files in /proc to begin with.  A better solution would be to use
> internally managed buffers and calls to write() instead of these stdio
> calls, but that would be a more extensive change; so this is proposed
> as a quick and not-so-dirty fix in the meantime.
> 
> Signed-off-by: Sean Finney <sean.finney@sonyericsson.com>
The same with this one... Committed!

steved.
