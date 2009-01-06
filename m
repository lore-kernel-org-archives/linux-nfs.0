From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/5] Fix legacy build issues
Date: Tue, 06 Jan 2009 12:44:24 -0500
Message-ID: <49639878.1080500@RedHat.com>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53872 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbZAFRqo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 12:46:44 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Hope your power is restored.
> 
> We discovered some problems building nfs-utils on legacy systems caused
> by recent IPv6 updates.  Here are some patches I propose to address
> those problems.
> 
> Jonathan Andrews has tested the C code introduced by "use gethostbyname(3)
> when building on old systems" on his distribution, which includes a very
> old version of glibc that doesn't support AI_ADDRCONFIG.  But I was a
> little challenged by the autoconf magic needed to pull this off.  Please
> have a close look at that to see if it really does what is needed.
> 
> ---
> 
> Chuck Lever (5):
>       configure: use "--disable-uuid" instead of "--without-uuid"
>       mount command: Random clean up
>       getport: don't use getaddrinfo(3) on old systems
>       mount command: use gethostbyname(3) when building on old systems
>       mount: revert recent fix for build problems on old systems
> 
> 
>  configure.ac          |   12 ++++++--
>  support/nfs/getport.c |   69 ++++++++++++++++++++++++++++++++++++++------
>  utils/mount/network.c |   77 +++++++++++++++++++++++++++++++++++++------------
>  3 files changed, 127 insertions(+), 31 deletions(-)
> 
Committed...

steved.
