Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbbAWPb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 10:31:28 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0NFVRk8018446
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 10:31:27 -0500
Message-ID: <54C2694E.6020108@RedHat.com>
Date: Fri, 23 Jan 2015 10:31:26 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] rpc.idmapd: Add a reference to nfsidmap(8)
 on the man page
References: <1419371092-18037-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1419371092-18037-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/23/2014 04:44 PM, Scott Mayhew wrote:
> Even though the 'new' idmapper used by the client has been around for
> several years, a lot of users seem to be unaware of its existence.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.

> ---
>  utils/idmapd/idmapd.man | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
> index 185cd1b..c809f78 100644
> --- a/utils/idmapd/idmapd.man
> +++ b/utils/idmapd/idmapd.man
> @@ -20,6 +20,16 @@ is the NFSv4 ID <-> name mapping daemon.  It provides functionality to
>  the NFSv4 kernel client and server, to which it communicates via
>  upcalls, by translating user and group IDs to names, and vice versa.
>  .Pp
> +Note that on more recent kernels only the NFSv4 server uses
> +.Nm .
> +The NFSv4 client instead uses
> +.Xr nfsidmap 8 ,
> +and only falls back to 
> +.Nm 
> +if there was a problem running the
> +.Xr nfsidmap 8
> +program.
> +.Pp
>  The options are as follows:
>  .Bl -tag -width Ds_imagedir
>  .It Fl v
> @@ -58,7 +68,8 @@ messages to console, and with a verbosity level of 3.
>  .Sh FILES
>  .Pa /etc/idmapd.conf
>  .Sh SEE ALSO
> -.Xr idmapd.conf 5
> +.Xr idmapd.conf 5 ,
> +.Xr nfsidmap 8
>  .\".Sh SEE ALSO
>  .\".Xr nylon.conf 4
>  .\" .Sh COMPATIBILITY
> 
