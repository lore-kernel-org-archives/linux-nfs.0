Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890Ab1ALQFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 11:05:01 -0500
Date: Wed, 12 Jan 2011 11:04:59 -0500
To: sdrb <sdrb@onet.eu>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, chuck.lever@oracle.com
Subject: Re: Issue in nfs-utils 1.2.3
Message-ID: <20110112160459.GA6124@fieldses.org>
References: <4D2D910F.1080703@onet.eu>
 <4D2DB1D8.8030606@onet.eu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D2DB1D8.8030606@onet.eu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 12, 2011 at 02:51:20PM +0100, sdrb wrote:
> I've investigated a little the sources and I noticed that probably
> there should be some pointer NULL-ed in mountlist_list() procedure
> like in patch I've attached.
> 
> Anyone can confirm that such a fix is ok?

Thanks for the report.

I haven't tried to verify that it could cause the backtrace you saw, but
clearly mlist is used after that mountlist_freeall(mlist), so your patch
is necessary.

Looks like this was introduced with a8348c2c4 "mountd: Add
mountlist_freeall()".

--b.

> diff -rNup nfs-utils-1.2.3_orig/utils/mountd/rmtab.c nfs-utils-1.2.3/utils/mountd/rmtab.c
> --- nfs-utils-1.2.3/utils/mountd/rmtab.c	2010-09-28 14:24:16.000000000 +0200
> +++ nfs-utils-1.2.3/utils/mountd/rmtab.c	2011-01-12 14:44:22.320000000 +0100
> @@ -205,6 +205,7 @@ mountlist_list(void)
>  	}
>  	if (stb.st_mtime != last_mtime) {
>  		mountlist_freeall(mlist);
> +		mlist=NULL;
>  		last_mtime = stb.st_mtime;
>  
>  		setrmtabent("r");

