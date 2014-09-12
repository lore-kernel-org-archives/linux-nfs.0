Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbaILRAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2014 13:00:20 -0400
Message-ID: <54132690.4090908@RedHat.com>
Date: Fri, 12 Sep 2014 13:00:00 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>,
        linux-nfs@vger.kernel.org, ncopa@alpinelinux.org
Subject: Re: [PATCH nfs-utils] rework access to /proc/net/rpc
References: <1407478301-9912-1-git-send-email-timo.teras@iki.fi>
In-Reply-To: <1407478301-9912-1-git-send-email-timo.teras@iki.fi>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 08/08/2014 02:11 AM, Timo Teräs wrote:
> The kernel support only access by read() and write() with exactly
> one line in the buffer. FILE can be implemented with readv() and
> writev(), and the mapping to syscalls is not guaranteed. The code
> already does lot of extra work setvbuf() and fflush() calls to try
> to ensure this, but it relays on implementation details and is
> non-portable. And e.g. with musl library the current hacks do not
> work at all.
> 
> Remove the FILE based qword_* API as it's fundamentally broken,
> and replace it with explicitly caching one line at a time. The
> qword API should probable improved to do the line caching
> internally, and this is the first step towards that.
> 
> Signed-off-by: Timo Teräs <timo.teras@iki.fi>
> ---
> This along with Natanael Copa's patchset makes nfs-utils somewhat
> usable with musl c-library.
First of all, I apologize for taking so long to get this patch.

Second of all, I'm going to NAK this patch because it breaks v3 mounts.
(Note: this patch was applied after Natanael patchset).

Using a Fedora 20 server, Fedora 20 clients fail with 
   mount.nfs: Unknown error 521 
and Fedora 21 clients fail with 
   mount.nfs: an incorrect mount option was specified

Also the following warnings occur after the patch is applied:

cache.c:128:21: warning: ignoring return value of 'write', declared with attribute warn_unused_result [-Wunused-result]
cache.c:1495:21: warning: ignoring return value of 'write', declared with attribute warn_unused_result [-Wunused-result]
nfssvc.c:71:8: warning: ignoring return value of 'system', declared with attribute warn_unused_result [-Wunused-result]
nfssvc.c:325:9: warning: ignoring return value of 'write', declared with attribute warn_unused_result [-Wunused-result]

My suggestion is to break the patch up into several small patches which
would help with debugging the problem.

I'll be more than willing to reconsider this change when it
stop braking v3 mounts and there are no warnings. 

steved.
 
