From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/5] new statd [take 1]
Date: Sun, 16 Aug 2009 16:35:02 -0400
Message-ID: <4A886D76.1040404@RedHat.com>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46773 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753624AbZHPUfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Aug 2009 16:35:10 -0400
In-Reply-To: <20090804180334.21944.64404.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/04/2009 02:06 PM, Chuck Lever wrote:
> Hi Steve-
> 
> Here are some man page patches and the one big patch that adds the new
> IPv6-capable statd.  I'd like to start socializing these changes to
> expedite the new statd into mainline nfs-utils.
> 
> ---
> 
> Chuck Lever (5):
>       nfs(5): update nfs(5) with details about IPv6 support
>       nfs-utils: introduce new statd implementation
I 'm waited on these to allow the new statd implementation to shake
out a bit port... 

>       statd: change default state dir to /var/lib/nfs/statd
I would like to get an 'ACK' from other distros on this one since
they could depending on what happens today...  

>       nfs(5): Remove trailing blanks
>       nfs(5): Add description of lookupcache mount option
I committed these

steved.
