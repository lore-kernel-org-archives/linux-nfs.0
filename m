Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066Ab3EGPHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 11:07:48 -0400
Message-ID: <5189189D.9060105@RedHat.com>
Date: Tue, 07 May 2013 11:07:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christopher T Vogan <cvogan@us.ibm.com>
CC: linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
Subject: Re: [Patch] nfs.man: Move nfsvers to "Options supported by all versions"
 section
References: <OF1B1919A7.AE5DDE4D-ON87257B39.0065E293-86257B39.0066DDA1@us.ibm.com> <OFC3D6E59E.970CBC4B-ON87257B57.00586B78-86257B57.00588757@us.ibm.com>
In-Reply-To: <OFC3D6E59E.970CBC4B-ON87257B57.00586B78-86257B57.00588757@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/04/13 12:06, Christopher T Vogan wrote:
> Does anyone agree or disagree with a man page update over the placement of 
> nfsvers/vers option?
Yeah.. this makes sense... I'll apply it... 

steved.

> 
> 
> Christopher Vogan
> Dept. W98 NFS Development & Test
> 
> 
> 
> From:   Christopher T Vogan/San Jose/IBM@IBMUS
> To:     linux-nfs@vger.kernel.org, 
> Date:   03/25/2013 01:48 PM
> Subject:        [Patch] nfs.man: Move nfsvers to "Options supported by all 
> versions" section
> Sent by:        linux-nfs-owner@vger.kernel.org
> 
> 
> 
> After inclusion of NFSv4.1 it seems that now you can specify an NFSv4 
> mount with either "-tnfs4" or "-overs=4".  I have prepared a patch that 
> moves "nfsvers/vers" from "Options for NFS versions 2 and 3 only" to 
> "Options supported by all versions".
> 
> Author: Chris Vogan <cvogan@us.ibm.com>
> Date:   Mon Mar 25 10:12:57 2013 -0700
> 
>     Update NFS man page to state that "nfsvers=/vers=" is suitable for all 
> 
> NFS version.
>     Move from "Options for NFS versions 2 and 3 only" to "Options 
> supported by all versions".
> 
>     Signed-off-by: Chris Vogan <cvogan@gmail.com>
> --- nfs-utils-1.2.7/utils/mount/nfs.man.save    2013-03-25 
> 10:05:57.781645020 -0700
> +++ nfs-utils-1.2.7/utils/mount/nfs.man 2013-03-25 10:12:57.013454158 
> -0700
> @@ -467,6 +467,18 @@
>  and <kernel_soruce>/Documentation/filesystems/caching
>  for detail on how to configure the FS-Cache facility.
>  Default value is nofsc.
> +.TP 1.5i
> +.BI nfsvers= n
> +The NFS protocol version number used to contact the server's NFS service.
> +If the server does not support the requested version, the mount request 
> fails.
> +If this option is not specified, the client negotiates a suitable version 
> 
> with
> +the server, trying version 4 first, version 3 second, and version 2 last.
> +.TP 1.5i
> +.BI vers= n
> +This option is an alternative to the
> +.B nfsvers
> +option.
> +It is included for compatibility with other operating systems.
>  .SS "Options for NFS versions 2 and 3 only"
>  Use these options, along with the options in the above subsection,
>  for NFS versions 2 and 3 only.
> @@ -613,18 +625,6 @@
>  reports the proper maximum component length to applications
>  in such cases.
>  .TP 1.5i
> -.BI nfsvers= n
> -The NFS protocol version number used to contact the server's NFS service.
> -If the server does not support the requested version, the mount request 
> fails.
> -If this option is not specified, the client negotiates a suitable version 
> 
> with
> -the server, trying version 4 first, version 3 second, and version 2 last.
> -.TP 1.5i
> -.BI vers= n
> -This option is an alternative to the
> -.B nfsvers
> -option.
> -It is included for compatibility with other operating systems.
> -.TP 1.5i
>  .BR lock " / " nolock
>  Selects whether to use the NLM sideband protocol to lock files on the 
> server.
>  If neither option is specified (or if
> 
> Christopher Vogan
> Dept. W98 NFS Development & Test
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
