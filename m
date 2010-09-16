From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #4)
Date: Thu, 16 Sep 2010 17:32:35 -0400
Message-ID: <4C928CF3.6030508@RedHat.com>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com> <4C921580.2050903@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab0IPVcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:32:45 -0400
In-Reply-To: <4C921580.2050903-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/16/2010 09:02 AM, Steve Dickson wrote:
> Hey Jeff,
> 
> Here is the patch with the L_WARNING change and the 
> s/else if/if change I just mentioned... 
> 
> steved.
> 
> Author: Jeff Layton <jlayton@redhat.com>
> Date:   Thu Sep 16 08:58:02 2010 -0400
>     
> There's a bit of a chicken and egg problem when nfsd is run the first
> time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
> is plugged in via a modprobe.conf "install" directive.
> 
> If someone runs rpc.nfsd without plugging in nfsd.ko first,
> /proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
> nfsctl interface. After that, nfsd will be plugged in and subsequent
> rpc.nfsd invocations will use that instead.
> 
> This is a problem as some nfsd command-line options are ignored when the
> legacy interface is used. It'll also be a problem for people who want
> IPv6 enabled servers. The upshot is that we really don't want to use the
> legacy interface unless there is no other option.
> 
> To avoid this situation, have rpc.nfsd check to see if the "threads"
> file is already present. If it's not, then make an attempt to mount
> /proc/fs/nfsd.  This is a "best-effort" sort of thing, however so we
> just ignore the return code from the mount attempt and fall back to
> using nfsctl() if it fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
