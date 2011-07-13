Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756907Ab1GMR3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 13:29:08 -0400
Message-ID: <4E1DD5E1.10700@RedHat.com>
Date: Wed, 13 Jul 2011 13:29:05 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Michael Guntsche <mike@it-loops.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Manpage corrections for nfs-utils 1.2.4
References: <20110713083828@it-loops.com>
In-Reply-To: <20110713083828@it-loops.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/13/2011 02:45 AM, Michael Guntsche wrote:
> Good morning,
> 
> I recently upgraded to 1.2.4 to use the new nfsidmap feature. While
> following the manpage and the kernel documentation I noticed a
> difference. Kernel docs mention key TYPE id_resolver while the manpage
> states nfs_idmap. The following patch changes the manpage to the proper
> type.
> 
> Kind regards,
> Michael Guntsche
Committed... Thank for the update! 

steved.
> 
> diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
> index 6c1a2d4..2381908 100644
> --- a/utils/nfsidmap/nfsidmap.man
> +++ b/utils/nfsidmap/nfsidmap.man
> @@ -25,9 +25,9 @@ will need to be modified so
>  can properly direct the upcall. The following line should be added before a call
>  to keyctl negate:
>  .PP
> -create	nfs_idmap	*	*	/usr/sbin/nfsidmap %k %d 600
> +create	id_resolver	*	*	/usr/sbin/nfsidmap %k %d 600
>  .PP
> -This will direct all nfs_idmap requests to the program
> +This will direct all id_resolver requests to the program
>  .I /usr/sbin/nfsidmap
>  The last parameter, 600, defines how many seconds into the future the key will
>  expire.  This is an optional parameter for
> @@ -48,9 +48,9 @@ You can choose to handle any of these individually, rather than using the
>  generic upcall program.  If you would like to use your own program for a uid
>  lookup then you would edit your request-key.conf so it looks similar to this:
>  .PP
> -create	nfs_idmap	uid:*	*	/some/other/program %k %d 600
> +create	id_resolver	uid:*	*	/some/other/program %k %d 600
>  .br
> -create	nfs_idmap	*		*	/usr/sbin/nfsidmap %k %d 600
> +create	id_resolver	*		*	/usr/sbin/nfsidmap %k %d 600
>  .PP
>  Notice that the new line was added above the line for the generic program.
>  request-key will find the first matching line and run the corresponding program.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
