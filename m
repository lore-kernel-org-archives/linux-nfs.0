Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f181.google.com ([209.85.128.181]:38105 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbaFEMi5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 08:38:57 -0400
Received: by mail-ve0-f181.google.com with SMTP id pa12so1091346veb.12
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 05:38:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <539026DB.30502@cn.fujitsu.com>
References: <539026DB.30502@cn.fujitsu.com>
Date: Thu, 5 Jun 2014 08:38:55 -0400
Message-ID: <CAHQdGtRzw-Aizqd1Q8Y9FAXZgp2jefn115F-ogcPA8VSuqA1Dw@mail.gmail.com>
Subject: Re: [PATCH]statd: create statdpath dir if specify the
 "--with-statdpath=xx" parameter in configure nfs-utils source code
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Ditang Chen <chendt.fnst@cn.fujitsu.com>
Cc: Steve Dickson <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 5, 2014 at 4:14 AM, Ditang Chen <chendt.fnst@cn.fujitsu.com> wrote:
> When configure the nfs-utils source code with "--with-statdpath=/foo" parameter，
> #define NSM_DEFAULT_STATEDIR "/foo" will be generated in support/include/config.h file,
> but Makefile will not create "/foo" dir.
>
> Signed-off-by: chendt.fnst@cn.fujitsu.com
> ---
>  Makefile.am | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/Makefile.am b/Makefile.am
> index ae7cd16..5c9ef44 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -54,10 +54,10 @@ install-data-hook:
>         touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
>         touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
>         touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
> -       mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
>         touch $(DESTDIR)$(statedir)/state
> -       chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
> -       -chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
> +       mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
> +       chmod go-rwx $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
> +       -chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
>

The file 'state' is owned by rpc.statd. Isn't it therefore also
subject to the --with-statdpath modifier?

At one point, the Fedora RPM packager even used to put it in
/var/lib/nfs/statd (as the manpage says it should) although that seems
to be broken now.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
