Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:56454 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab2EQRPT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 13:15:19 -0400
Message-ID: <4FB532D1.5090402@panasas.com>
Date: Thu, 17 May 2012 10:18:09 -0700
From: Sachin Bhamare <sbhamare@panasas.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        "Harrosh, Boaz" <bharrosh@panasas.com>
Subject: Re: ANNOUNCE: nfs-utils-1.2.6 released.
References: <4FB159DA.2070800@RedHat.com> <20120517164420.3fe761a5@notabene.brown>
In-Reply-To: <20120517164420.3fe761a5@notabene.brown>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/16/12 11:44 PM, NeilBrown wrote:
> On Mon, 14 May 2012 15:15:38 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>> New Features in this release:
>>    * The addition the nfsdcld daemon
>>    * The addition of the osd_login script which is mandated by the
>>          pnfs-objects standard
> 
> Don't you hate it when people don't bother to test all your -rc's, then
> report bugs against your final release?  Me too.
> 
>   mkdir /tmp/dest
>   make DESTDIR=/tmp/dest install
> 
> fails because it tries to install osd_login in /tmp/dest/sbin/osd_login
> without first creating /tmp/dest/sbin.  All other required directories get
> created first.
> 
> This patch - stealing an idea from utils/mount - seem to fix it.
> 
> Thanks,
> NeilBrown
> 
> 
> commit 03bb227402ab023f4badb515022d49f82e01ff8d
> Author: Neil Brown <neilb@suse.de>
> Date:   Thu May 17 16:40:40 2012 +1000
> 
>     osd_login - ensure /sbin is created before installation.
>     
>     If we use a more standard approach to describing the osd_login
>     script, the automake infrastructure will create /sbin before
>     attempting installation.
>     This is important for: make DESTDIR=/empty-dir install
>     
>     Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
> index adc493a..d17ffa7 100644
> --- a/utils/osd_login/Makefile.am
> +++ b/utils/osd_login/Makefile.am
> @@ -1,12 +1,9 @@
>  ## Process this file with automake to produce Makefile.in
>  
> -OSD_LOGIN_FILES= osd_login
> +# These binaries go in /sbin (not /usr/sbin), and that cannot be
> +# overriden at config time.
> +sbindir = /sbin
>  
> -EXTRA_DIST= $(OSD_LOGIN_FILES)
> -
> -all-local: $(OSD_LOGIN_FILES)
> -
> -install-data-hook:
> -	$(INSTALL) --mode 755 osd_login $(DESTDIR)/sbin/osd_login
> +sbin_SCRIPTS = osd_login
>  
>  MAINTAINERCLEANFILES = Makefile.in

ACK-by: Sachin Bhamare <sbhamare@panasas.com>

Thanks for fixing this. My bad for not testing it with a non-empty DESTDIR.

- sachin

-----
Sachin Bhamare
Panasas Inc.
