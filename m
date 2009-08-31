From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: Ignore vers=4
Date: Mon, 31 Aug 2009 08:44:03 -0400
Message-ID: <4A9BC593.4070405@RedHat.com>
References: <20090830163617.4608.48355.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbZHaMoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 08:44:10 -0400
In-Reply-To: <20090830163617.4608.48355.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/30/2009 12:37 PM, Chuck Lever wrote:
> Since mount.nfs looks at the vers= option to determine pmap parameters when
> negotiating, it throws EINVAL if "4" is specified, even if the kernel
> supports vers=4 for "nfs" type file systems.
> 
> Teach mount.nfs to ignore vers=4 and just pass the options to the kernel.
How will mount.nfs know that the kernel now supports the "vers=4" option?

steved
