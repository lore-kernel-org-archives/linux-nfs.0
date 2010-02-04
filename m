From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] nfsd: fix version-setting regression on old kernels
Date: Thu, 04 Feb 2010 16:37:52 -0500
Message-ID: <4B6B3E30.8090907@RedHat.com>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755835Ab0BDVh4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 16:37:56 -0500
In-Reply-To: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/27/2010 05:26 PM, J. Bruce Fields wrote:
> /proc/fs/nfsd/versions was extended to allow turning on/off minor
> versions by echoing "+4.1" or "-4.1" to /proc/fs/nsfd/versions.
> 
> Unfortunately, pre-2.6.30 kernels just stop parsing at first non-digit,
> so "-4.1" is interpreted as "-4".  If new nfs-utils (on old kernel)
> writes "+2", "+3", "+4", then "-4.1", result therefore is to turn off
> 4.1.
> 
> Given that historical behavior, it may have been a mistake to extend the
> interface the way we did; but at this point we're probably stuck with
> it.  So, just reverse the order we write versions in.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  utils/nfsd/nfssvc.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index b8028bb..7bbbaba 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -238,17 +238,17 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers4)
>  	if (fd < 0)
>  		return;
>  
> +	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
> +	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
> +		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d",
There needs to be a space between the %d and ".

But more importantly what problem is the patch fixing?? I've tested this
on a 2.6.29 and 2.6.31 as well as a 2.6.33 kernel and I see no different
in how the versions are ordered.
 
Note, as you probably already know, the kernel will always display
the versions in descending order...

steved.
 
