Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932135AbaFQSGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2014 14:06:33 -0400
Message-ID: <53A083A4.4020304@RedHat.com>
Date: Tue, 17 Jun 2014 14:06:28 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Ditang Chen <chendt.fnst@cn.fujitsu.com>
CC: Trond Myklebust <trond.myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "yaoxp@cn.fujitsu.com" <yaoxp@cn.fujitsu.com>
Subject: Re: [PATCH]statd: create statdpath dir if specify the "--with-statdpath=xx"
 parameter in configure nfs-utils source code
References: <539026DB.30502@cn.fujitsu.com> <539132AF.8060805@cn.fujitsu.com>
In-Reply-To: <539132AF.8060805@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/05/2014 11:17 PM, Ditang Chen wrote:
> When configure the nfs-utils source code with "--with-statdpath=/foo" parameter，
> #define NSM_DEFAULT_STATEDIR "/foo" will be generated in support/include/config.h file,
> but Makefile will not create "/foo" dir.
> 
> Signed-off-by: chendt.fnst@cn.fujitsu.com
> Reported-by: yaoxp@cn.fujitsu.com
> ---
>  Makefile.am | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
Committed.... 

steved
> 
> diff --git a/Makefile.am b/Makefile.am
> index ae7cd16..5824adc 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -54,13 +54,13 @@ install-data-hook:
>         touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
>         touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
>         touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
> -       mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
> -       touch $(DESTDIR)$(statedir)/state
> -       chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
> -       -chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
> +       mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
> +       touch $(DESTDIR)$(statdpath)/state
> +       chmod go-rwx $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statdpath)/state
> +       -chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statdpath)/state
> 
>  uninstall-hook:
>         rm $(DESTDIR)$(statedir)/xtab
>         rm $(DESTDIR)$(statedir)/etab
>         rm $(DESTDIR)$(statedir)/rmtab
> -       rm $(DESTDIR)$(statedir)/state
> +       rm $(DESTDIR)$(statdpath)/state
> 
