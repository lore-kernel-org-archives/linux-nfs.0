From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/5] Fix legacy build issues
Date: Wed, 17 Dec 2008 15:42:34 -0500
Message-ID: <D592BA80-E74E-426C-8D50-E6E24E02B261@oracle.com>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:61579 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbYLQUnE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:43:04 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I promise this is the last set for 2008.

See you next year. :-)


On Dec 17, 2008, at Dec 17, 2008, 3:37 PM, Chuck Lever wrote:

> Hi Steve-
>
> Hope your power is restored.
>
> We discovered some problems building nfs-utils on legacy systems  
> caused
> by recent IPv6 updates.  Here are some patches I propose to address
> those problems.
>
> Jonathan Andrews has tested the C code introduced by "use  
> gethostbyname(3)
> when building on old systems" on his distribution, which includes a  
> very
> old version of glibc that doesn't support AI_ADDRCONFIG.  But I was a
> little challenged by the autoconf magic needed to pull this off.   
> Please
> have a close look at that to see if it really does what is needed.
>
> ---
>
> Chuck Lever (5):
>      configure: use "--disable-uuid" instead of "--without-uuid"
>      mount command: Random clean up
>      getport: don't use getaddrinfo(3) on old systems
>      mount command: use gethostbyname(3) when building on old systems
>      mount: revert recent fix for build problems on old systems
>
>
> configure.ac          |   12 ++++++--
> support/nfs/getport.c |   69 +++++++++++++++++++++++++++++++++++++ 
> +------
> utils/mount/network.c |   77 ++++++++++++++++++++++++++++++++++++ 
> +------------
> 3 files changed, 127 insertions(+), 31 deletions(-)
>
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




