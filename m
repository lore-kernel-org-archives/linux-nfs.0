From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Restore missing hunk in NFS mount option parser
Date: Fri, 5 Sep 2008 17:11:10 -0400
Message-ID: <20080905211110.GE12947@fieldses.org>
References: <20080905181339.17103.36231.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57708 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbYIEVLU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 17:11:20 -0400
In-Reply-To: <20080905181339.17103.36231.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 05, 2008 at 02:16:07PM -0400, Chuck Lever wrote:
> Commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a was missing a hunk that
> prevented the new "sloppy" mount option from having any effect.

I don't think that on its own would justify sending it in for 2.6.27.[1]

> 
> Tested against 2.6.27-rc.  2.6.26 is not affected.

But if I understand right, the effect of leaving out this chunk was to
make the *default* behavior "sloppy"?  Which seems a drastic change from
the previous behavior.  And it's a simple enough patch.

So I'd be inclined to agree and send it in for 2.6.27....  If Trond
doesn't poke his head up by tomorrow, let's go ahead--feel free to send
it to Linus with my

	Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

if I fall off the face of the earth tomorrow.

--b.

[1] Linus has been pretty hard on -rc patches lately:

	http://marc.info/?l=linux-netdev&m=122048427801318&w=2

	"Here's a simple rule of thumb:
	 - if it's not on the regression list
	 - if it's not a reported security hole
	 - if it's not on the reported oopses list
	then why are people sending it to me?"


> 
> Thanks to Neil Brown for reporting this.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/super.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 5b2aa04..e3ac650 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1279,6 +1279,12 @@ static int nfs_parse_mount_options(char *raw,
>  		}
>  	}
>  
> +	if (errors > 0) {
> +		dfprintk(MOUNT, "NFS: parsing encountered %d error%s\n",
> +				errors, (errors == 1 ? "" : "s"));
> +		if (!sloppy)
> +			return 0;
> +	}
>  	return 1;
>  
>  out_nomem:
> 
