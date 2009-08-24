From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Fwd: mount.nfs: access denied by server
Date: Mon, 24 Aug 2009 08:15:39 -0400
Message-ID: <4A92846B.2080200@RedHat.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182027.GD21043@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312AbZHXMQI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 08:16:08 -0400
In-Reply-To: <20090821182027.GD21043@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/21/2009 02:20 PM, J. Bruce Fields wrote:
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Tue Jul 21 19:30:04 2009 -0400
> 
>     Don't give client an empty flavor list
>     
>     In the absence of an explicit sec= option on an export, rpc.mountd is
>     returning a zero-length flavor list to clients in the MOUNT results.
>     
>     The linux client doesn't seem to mind, but the Solaris client
>     (reasonably enough) is giving up; the symptom is a "security mode does
>     not match" error on mount.
>     
>     We could modify the export-parsing code to ensure the secinfo array is
>     nonzero.  But I think it's slightly simpler to handle this default case
>     in the implementation of the MOUNT call.  This is more-or-less the same
>     thing the kernel does when mountd passes it an export without any
>     security flavors specified.
>     
>     Thanks to Tom Haynes for bug report and diagnosis.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index b59f939..888fd8c 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -359,6 +359,11 @@ static void set_authflavors(struct mountres3_ok *ok, nfs_export *exp)
>  		flavors[i] = s->flav->fnum;
>  		i++;
>  	}
> +	if (i == 0) {
> +		/* default when there is no sec= option: */
> +		i = 1;
> +		flavors[0] = AUTH_UNIX;
> +	}
>  	ok->auth_flavors.auth_flavors_val = flavors;
>  	ok->auth_flavors.auth_flavors_len = i;
>  }

Committed.... 

steved.

