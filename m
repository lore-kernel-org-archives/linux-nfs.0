From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] fsid export option broken in 2.6
Date: Fri, 6 Aug 2004 14:41:39 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16659.3076.2507.302382@cse.unsw.edu.au>
References: <1091565494.4797.39.camel@dyn319492.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BswYR-0002aY-Ee
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 21:42:07 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BswYR-0006eK-0z
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 21:42:07 -0700
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: message from Bruce Allan on Tuesday August 3
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tuesday August 3, bwa@us.ibm.com wrote:
> The user-specified fsid= export option still doesn't work after the
> changes made 5 months ago.  Below is a patch against 2.6.7 through
> the recent 2.6.8-rc2-bk13.

Thanks.  The current code is obviously wrong.  Who could have written
such rubbish..... bkbits tells all, it was me :-(

I'll forward it to Andrew shortly.

NeilBrown

> 
> --- linux-2.6.7~current~/fs/nfsd/nfsfh.c	2004-06-15 22:19:13.000000000 -0700
> +++ linux-2.6.8-rc2-bk13/fs/nfsd/nfsfh.c	2004-08-03 05:42:23.896776312 -0700
> @@ -339,13 +339,16 @@ fh_compose(struct svc_fh *fhp, struct sv
>  			ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
>  		if (ref_fh_fsid_type > 3)
>  			ref_fh_fsid_type = 0;
> -	}
> -	/* make sure ref_fh type works for given export */
> -	if (ref_fh_fsid_type == 1 &&
> -	    !(exp->ex_flags & NFSEXP_FSID)) {
> -		/* if we don't have an fsid, we cannot provide one... */
> -		ref_fh_fsid_type = 0;
> -	}
> +
> +		/* make sure ref_fh type works for given export */
> +		if (ref_fh_fsid_type == 1 &&
> +		    !(exp->ex_flags & NFSEXP_FSID)) {
> +			/* if we don't have an fsid, we cannot provide one... */
> +			ref_fh_fsid_type = 0;
> +		}
> +	} else if (exp->ex_flags & NFSEXP_FSID)
> +			ref_fh_fsid_type = 1;
> +
>  	if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
>  		/* for newer device numbers, we must use a newer fsid format */
>  		ref_fh_version = 1;
> 
> Regards,
> ---
> Bruce Allan  <bruce.allan@us.ibm.com>
> Software Engineer, Linux Technology Center
> IBM Corporation, Beaverton OR
> 503-578-4187   IBM Tie-line 775-4187
> 


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
