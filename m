Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754004AbaKEQRW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 11:17:22 -0500
Message-ID: <545A4D8E.5010106@RedHat.com>
Date: Wed, 05 Nov 2014 11:17:18 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc.svcgssd: Add a configure switch to disable building
 the daemon
References: <1411489301-28991-1-git-send-email-steved@redhat.com>	<1411489301-28991-2-git-send-email-steved@redhat.com> <20141105135633.4ea63a2c@notabene.brown>
In-Reply-To: <20141105135633.4ea63a2c@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/04/2014 09:56 PM, NeilBrown wrote:
> Hi Steve,
>  I just noticed that this causes an error when I try "./configure".
> It tries to run a program called "enable_svcgss" with args "=" and "yes",
> but this fails....
> 
> A simple fix would leave the code doing nothing if enable_gss = yes, but
> enable_svcgss = no.  Is that what you want?
No... 

> 
> Should it be:
> 
>         if test "$enable_gss" = yes -a "$enable_svcgss" = yes; then
>                 SVCGSSD=svcgssd
>> > +	else
>> > +		enable_svcgss=
>> > +		SVCGSSD=
>> > +	fi
> ??
> 
> Would you like a patch, or will you just fix it up?
I got it... thanks! 

commit e186d734cb3d7c53ef8038b2f62e5b1825d9fa26
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Nov 5 11:12:03 2014 -0500

    configure: Fixed logic around $enable_gss and $enable_svcgss
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/configure.ac b/configure.ac
index 59fd14d..377ba2e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -108,10 +108,8 @@ AC_ARG_ENABLE(svcgss,
     [enable building svcgssd for rpcsec_gss server support @<:@default=yes@:>@])],
        enable_svcgss=$enableval,
        enable_svcgss=yes)
-       if test "$enable_gss" = yes; then
-               if "enable_svcgss" = yes; then
-                       SVCGSSD=svcgssd
-               fi
+       if test "$enable_gss" = yes -a "enable_svcgss" = yes; then
+               SVCGSSD=svcgssd
        else
                enable_svcgss=
                SVCGSSD=


steved.
