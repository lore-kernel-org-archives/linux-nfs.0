Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136Ab2K1Ty7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 14:54:59 -0500
Message-ID: <50B66BE8.3070200@RedHat.com>
Date: Wed, 28 Nov 2012 14:54:16 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Make size of gssd_proc fd array a little more dynamic
References: <20121128010939.2475.13123.stgit@notabene.brown>
In-Reply-To: <20121128010939.2475.13123.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 27/11/12 20:11, Neil Brown wrote:
> We recently had a request to raise the number of fds that gssd can
> work with - again.
> 
> Rather than just change the hard-coded number I seemed to make sense
> to have it depend on RLIMIT_NOFILE - as poll won't work with more than
> that anyway.
> So the default becomes 1024, but it is easily raised further without
> code change.
> 
> These patches implement that.
All three packages were committed...

steved.

> 
> NeilBrown
> 
> 
> ---
> 
> Neil Brown (3):
>       gssd_proc: use pollsize, not FD_ALLOC_BLOCK, in get_poll_index().
>       gssd_proc: remove pointless test against FD_ALLOC_BLOCK in process_pipedir
>       gssd: base the size of the fd array on the RLIMIT_NOFILE limit.
> 
> 
>  utils/gssd/gssd_proc.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
