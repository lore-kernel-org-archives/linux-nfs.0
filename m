Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbaCKTHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 15:07:32 -0400
Message-ID: <531F511D.1000009@RedHat.com>
Date: Tue, 11 Mar 2014 14:08:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Aaro Koskinen <aaro.koskinen@iki.fi>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] tools: use install -m instead of --mode
References: <1393621584-15467-1-git-send-email-aaro.koskinen@iki.fi>
In-Reply-To: <1393621584-15467-1-git-send-email-aaro.koskinen@iki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/28/2014 04:06 PM, Aaro Koskinen wrote:
> Use install -m instead of--mode for better compatibility.
> E.g. busybox's install doesn't support the long option.
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
Committed...

steved.

> ---
>  tools/mountstats/Makefile.am | 2 +-
>  tools/nfs-iostat/Makefile.am | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/mountstats/Makefile.am b/tools/mountstats/Makefile.am
> index ca617a2..c2e9f99 100644
> --- a/tools/mountstats/Makefile.am
> +++ b/tools/mountstats/Makefile.am
> @@ -8,6 +8,6 @@ EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
>  all-local: $(PYTHON_FILES)
>  
>  install-data-hook:
> -	$(INSTALL) --mode 755 mountstats.py $(DESTDIR)$(sbindir)/mountstats
> +	$(INSTALL) -m 755 mountstats.py $(DESTDIR)$(sbindir)/mountstats
>  
>  MAINTAINERCLEANFILES=Makefile.in
> diff --git a/tools/nfs-iostat/Makefile.am b/tools/nfs-iostat/Makefile.am
> index 30f4054..3ae0f29 100644
> --- a/tools/nfs-iostat/Makefile.am
> +++ b/tools/nfs-iostat/Makefile.am
> @@ -8,6 +8,6 @@ EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
>  all-local: $(PYTHON_FILES)
>  
>  install-data-hook:
> -	$(INSTALL) --mode 755 nfs-iostat.py $(DESTDIR)$(sbindir)/nfsiostat
> +	$(INSTALL) -m 755 nfs-iostat.py $(DESTDIR)$(sbindir)/nfsiostat
>  
>  MAINTAINERCLEANFILES=Makefile.in
> 
