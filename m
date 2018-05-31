Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53668 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755025AbeEaPNZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 11:13:25 -0400
Subject: Re: nfs-utils-2.3.2: glitch crashes build
To: gabriele balducci <balducci@units.it>, linux-nfs@vger.kernel.org
References: <11745.1527438384@dschgrazlin2.units.it>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <965f2a16-dc1e-39e0-80f8-f55166a5106e@RedHat.com>
Date: Thu, 31 May 2018 11:13:23 -0400
MIME-Version: 1.0
In-Reply-To: <11745.1527438384@dschgrazlin2.units.it>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello gabriele

I wonder why I am not seeing these warnings... 

Thank you very much for the patch... Would you
mind if I added a 
   Signed-off-by: gabriele balducci <balducci@units.it>

to the official patch? 

steved.
On 05/27/2018 12:26 PM, gabriele balducci wrote:
> hello
> 
> building 2.3.2 fails with:
> 
>   mountd.c:706:3: note: 'sprintf' output between 6 and 16 bytes into a destination of size 10
>      sprintf(tag, "vers%d", vers);
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
>   cc1: some warnings being treated as errors
> 
> and
> 
>   nfsd.c:102:3: note: 'sprintf' output between 6 and 16 bytes into a destination of size 10
>      sprintf(tag, "vers%d", i);
>      ^~~~~~~~~~~~~~~~~~~~~~~~~
>   cc1: some warnings being treated as errors
> 
> I guess the reason is (https://marc.info/?l=linux-nfs&m=152718306728854&w=2):
> 
>     * Most compile warnings are now fatal errors.
> 
> and (configure):
> 
>   checking whether CC supports -Werror=format-overflow=2... yes
> 
> This fixes everything for me:
> 
>   diff -c utils/mountd/mountd.c.FIX_VAR_DIM utils/mountd/mountd.c
>   *** utils/mountd/mountd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
>   --- utils/mountd/mountd.c	Sun May 27 18:16:46 2018
>   ***************
>   *** 702,708 ****
>           else
>                   NFSCTL_TCPUNSET(_rpcprotobits);
>           for (vers = 2; vers <= 4; vers++) {
>   ! 		char tag[10];
>                   sprintf(tag, "vers%d", vers);
>                   if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(nfs_version, vers)))
>                           NFSCTL_VERSET(nfs_version, vers);
>   --- 702,708 ----
>           else
>                   NFSCTL_TCPUNSET(_rpcprotobits);
>           for (vers = 2; vers <= 4; vers++) {
>   ! 		char tag[20];
>                   sprintf(tag, "vers%d", vers);
>                   if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(nfs_version, vers)))
>                           NFSCTL_VERSET(nfs_version, vers);
> 
> 
> 
>   diff -c utils/nfsd/nfsd.c.FIX_VAR_DIM utils/nfsd/nfsd.c
>   *** utils/nfsd/nfsd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
>   --- utils/nfsd/nfsd.c	Sun May 27 18:16:46 2018
>   ***************
>   *** 98,104 ****
>           else
>                   NFSCTL_TCPUNSET(protobits);
>           for (i = 2; i <= 4; i++) {
>   ! 		char tag[10];
>                   sprintf(tag, "vers%d", i);
>                   if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
>                           NFSCTL_VERSET(versbits, i);
>   --- 98,104 ----
>           else
>                   NFSCTL_TCPUNSET(protobits);
>           for (i = 2; i <= 4; i++) {
>   ! 		char tag[20];
>                   sprintf(tag, "vers%d", i);
>                   if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
>                           NFSCTL_VERSET(versbits, i);
> 
> 
> I thought the maintainers might be interested in fixing upstream
> 
> ciao
> gabriele
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
