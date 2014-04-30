Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759258AbaD3RQT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 13:16:19 -0400
Message-ID: <53612FDE.1060303@RedHat.com>
Date: Wed, 30 Apr 2014 13:16:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: PATCH - nfs-utils] nfsdctltrack: ensure binary is installed in
 /sbin
References: <20140415175424.68a318e2@notabene.brown>
In-Reply-To: <20140415175424.68a318e2@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/15/2014 03:54 AM, NeilBrown wrote:
> 
> The kernel "knows" this lives in /sbin, so just like
> mount.nfs and osd_login, it must unconditionally be installed
> there.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.

> 
> diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
> index a860ffb82e2c..7524295f394e 100644
> --- a/utils/nfsdcltrack/Makefile.am
> +++ b/utils/nfsdcltrack/Makefile.am
> @@ -1,5 +1,9 @@
>  ## Process this file with automake to produce Makefile.in
>  
> +# These binaries go in /sbin (not /usr/sbin), and that cannot be
> +# overridden at config time. The kernel "knows" the /sbin name.
> +sbindir = /sbin
> +
>  man8_MANS	= nfsdcltrack.man
>  EXTRA_DIST	= $(man8_MANS)
>  
> 
