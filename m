From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/3] libnsm.a: sm-notify sometimes ignores monitored hosts
Date: Mon, 13 Dec 2010 14:59:20 -0500
Message-ID: <4D067B18.2020201@RedHat.com>
References: <20101206160206.18361.26178.stgit@matisse.1015granger.net> <20101206160944.18361.28275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766Ab0LMT70 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 14:59:26 -0500
In-Reply-To: <20101206160944.18361.28275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2010 11:09 AM, Chuck Lever wrote:
> Monitored host information is stored in files under /var/lib/nfs.
> When visiting entries in the monitored hosts directory, libnsm.a
> examines the value of dirent.d_type to determine if an entry is a
> regular file.
> 
> According to readdir(3), the d_type field is not supported by all
> file system types.  My root file system happens to be one where d_type
> isn't supported.  Typical installations that use an ext-derived root
> file system are not exposed to this issue, but those who use xfs, for
> instance, are.
> 
> On such file systems, not only are remote peers not notified of
> reboots, but the NSM state number is never incremented.  A statd warm
> restart would not re-monitor any hosts that were monitored before
> the restart.
> 
> When writing support/nsm/file.c, I copied the use of d_type from the
> original statd code, so this has likely been an issue for some time.
> 
> Replace the use of d_type in support/nsm/file.c with a call to
> lstat(2).  It's extra code, but is guaranteed to work on all file
> system types.
> 
> Note there is a usage of d_type in gssd.  I'll let gssd and rpcpipefs
> experts decide whether that's worth changing.
> 
> Fix for:
> 
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=193
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... But without the "Skipping dot file..." xlogs.

steved
