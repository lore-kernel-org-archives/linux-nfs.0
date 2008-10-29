From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Wed, 29 Oct 2008 13:18:41 -0400
Message-ID: <20081029171841.GC31936@fieldses.org>
References: <1225239200402@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36859 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbYJ2RSn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 13:18:43 -0400
In-Reply-To: <1225239200402-YnoLgZYwwYuCbKHnblo0pmrPP3OPMK55cpQHUIT47Ck@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2008 at 12:13:20AM +0000, Phil Endecott wrote:
> Dear Experts,
> 
> sm-notify was taking a long time while my laptop booted.  This was odd because I 
> use NFS only rarely - via autofs - on that machine, and sm-notify actually has 
> no-one to notify most of the time.  So I have patched it as follows.  Is this a 
> legitimate thing to do?

It looks like your patch was committed to nfs-utils a couple weeks ago:
see c8d18e26d2a53d9036a32c2dafebccaf4ce1634d from

	git://linux-nfs.org/nfs-utils

--b.

> 
> 
> diff -ur nfs-utils-1.1.3.orig/utils/statd/sm-notify.c nfs-utils-1.1.3/utils/statd/sm-notify.c
> --- nfs-utils-1.1.3.orig/utils/statd/sm-notify.c	2008-07-27 22:01:45.000000000 +0100
> +++ nfs-utils-1.1.3/utils/statd/sm-notify.c	2008-10-13 19:02:54.000000000 +0100
> @@ -169,6 +169,10 @@
>  	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
>  	get_hosts(_SM_BAK_PATH);
>  
> +	if (!hosts) {
> +		return 0;
> +	}
> +
>  	/* Get and update the NSM state. This will call sync() */
>  	nsm_state = nsm_get_state(opt_update_state);
>  	set_kernel_nsm_state(nsm_state);
> 
> 
> 
> Regards,  Phil.
> (Please Cc: me in any replies.)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
