From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/7] nfsd4: edit comment for concision
Date: Wed, 03 Mar 2010 13:06:31 -0500
Message-ID: <4B8EA527.5060502@oracle.com>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu> <1267571573-11844-2-git-send-email-bfields@citi.umich.edu> <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29117 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab0CCSH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Mar 2010 13:07:57 -0500
In-Reply-To: <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/02/2010 06:12 PM, J. Bruce Fields wrote:
> Also note units are seconds.

I'd prefer the major edits in this patch be done at the same time you 
trim the other documenting comments for the /proc/fs/nfsd API.

> Signed-off-by: J. Bruce Fields<bfields@citi.umich.edu>
> ---
>   fs/nfsd/nfsctl.c |   21 ++++++---------------
>   1 files changed, 6 insertions(+), 15 deletions(-)
>
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 8bff674..f1ee549 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1228,23 +1228,14 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
>   /**
>    * write_leasetime - Set or report the current NFSv4 lease time
>    *
> - * Input:
> - *			buf:		ignored
> - *			size:		zero
> + * If given a nonzero size, sets the NFSv4 lease time to a number of
> + * seconds (interpreting buf as a C string containing an ascii
> + * representation of the number).
>    *
> - * OR
> + * Returns the resulting lease time (as an ascii representation in a
> + * '\n'-terminated C string) in buf.
>    *
> - * Input:
> - *			buf:		C string containing an unsigned
> - *					integer value representing the new
> - *					NFSv4 lease expiry time
> - *			size:		non-zero length of C string in @buf
> - * Output:
> - *	On success:	passed-in buffer filled with '\n'-terminated C
> - *			string containing unsigned integer value of the
> - *			current lease expiry time;
> - *			return code is the size in bytes of the string
> - *	On error:	return code is zero or a negative errno value
> + * Given a zero size, just returns the lease time in buf.
>    */
>   static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
>   {


-- 
chuck[dot]lever[at]oracle[dot]com
