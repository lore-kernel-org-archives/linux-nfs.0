Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4210 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759571Ab3IEMuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 08:50:23 -0400
Date: Thu, 5 Sep 2013 08:50:17 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Dros Adamson <Weston.Adamson@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-ID: <931669980.21.1378385417507.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <FA5ED61A-3218-4E18-816D-FDAA948BED48@netapp.com>
Subject: Re: [PATCH] NFSv4: use mach cred for SECINFO_NO_NAME w/ integrity
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

----- "Dros Adamson" <Weston.Adamson@netapp.com> wrote:

> On Sep 4, 2013, at 12:29 PM, Matt W. Benjamin <matt@linuxbox.com>
> wrote:
> 
> > Hi
> > 
> > It honestly feels quite odd to me for sec=sys to actually connote
> krb5i.
> 
> I should point out that my patches don't introduce the use of krb5i
> here, they just fix it.

Ack.

> 
> I personally don't think it's weird for the client to use a *more*
> secure flavor for certain (infrequent) operations when it makes sense.
> What worries me that currently sec=krb5p can cross a SECINFO boundary
> and suddenly be using sec=sys!

I think the behavior is obviously reasonable, but giving that policy a
different name would allow sec=sys to continue mean what it says.    

> 
> I'm testing patches that fix that now and also allow multiple sec=
> options (in the same form as nfsd exports, i.e. sec=krb5:krb5i, but
> I'm trying to fix all the recent regressions surrounding auth flavors
> / SECINFO first...

That sounds great.

> 
> -dros
> 
> > 

Thanks,

Matt

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
