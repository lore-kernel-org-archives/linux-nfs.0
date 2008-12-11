From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Thu, 11 Dec 2008 11:06:54 -0500
Message-ID: <49413A9E.1000007@RedHat.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39755 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756341AbYLKQLO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Dec 2008 11:11:14 -0500
In-Reply-To: <20081202175403.5206.91389.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Here's the next step.
> 
> This small series of patches rewires probe_bothports() to support
> AF_INET6 addresses, now that the underlying functions can handle them.
> 
> Since legacy code in other parts of the mount command still use
> probe_bothports() and the clnt_addr_t data type, I've added a new
> function call to do the IPv6 duties.  The old API still exists and
> continues to support only AF_INET, but under the covers it calls the
> new code.
> 
> Again, for the time being, this is used only for the legacy binary
> mount(2) interface.  We will need this for umount later, and that is
> used to support both binary and text-based mounts.
> 
All three patches have been committed... Again sorry for the delay.

That darn flux capacitor keeps breaking all the time
which always seems to get in the way...  ;-)

steved.

