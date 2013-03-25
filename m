Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757816Ab3CYORv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:17:51 -0400
Message-ID: <51505C6D.2080402@RedHat.com>
Date: Mon, 25 Mar 2013 10:17:17 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christopher T Vogan <cvogan@us.ibm.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS man page patch that moves nordirplus/rdirplus
References: <OF0365F8D8.55071FDA-ON87257B33.00762456-86257B33.00765660@us.ibm.com>
In-Reply-To: <OF0365F8D8.55071FDA-ON87257B33.00762456-86257B33.00765660@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/03/13 17:32, Christopher T Vogan wrote:
> NFS man page patch that moves nordirplus/rdirplus from "Options for NFS 
> versions 2 and 3 only" to "Options supported by all versions".  Its a 
> better fit here since this option is also needed for some NFSv4 servers.
> 
> 
> Author: Chris Vogan <cvogan@us.ibm.com>
> Date:   Fri Feb 28 14:40:11 2013 -0700
> 
>     NFS man page needs updating to clarify that nordirplus mount option
>     is also valid for NFSv4. Also should be moved to the section
>     "Options supported by all versions".
> 
>     Signed-off-by: Chris Vogan <cvogan@gmail.com>
Committed...

steved.
> --- nfs.man.save        2013-02-28 14:40:11.530103375 -0700
> +++ nfs.man     2013-02-28 14:42:48.028996087 -0700
> @@ -345,6 +345,13 @@
>  .BR automount (8)
>  for details).
>  .TP 1.5i
> +.BR rdirplus " / " nordirplus
> +Selects whether to use NFS v3 or v4 READDIRPLUS requests.
> +If this option is not specified, the NFS client uses READDIRPLUS requests
> +on NFS v3 or v4 mounts to read small directories.
> +Some applications perform better if the client uses only READDIR requests
> +for all directories.
> +.TP 1.5i
>  .BI retry= n
>  The number of minutes that the
>  .BR mount (8)
> @@ -710,13 +717,6 @@
>  Disabling the NFSACL sideband protocol may be necessary
>  if the negotiation causes problems on the client or server.
>  Refer to the SECURITY CONSIDERATIONS section for more details.
> -.TP 1.5i
> -.BR rdirplus " / " nordirplus
> -Selects whether to use NFS version 3 READDIRPLUS requests.
> -If this option is not specified, the NFS client uses READDIRPLUS requests
> -on NFS version 3 mounts to read small directories.
> -Some applications perform better if the client uses only READDIR requests
> -for all directories.
>  .SS "Options for version 4 only"
>  Use these options, along with the options in the first subsection above,
>  for NFSv4 only. They will be ignored with older versions.
> 
> 
> Christopher Vogan
> Dept. W98 NFS Development & Test
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
