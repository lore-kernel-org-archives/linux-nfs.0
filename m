Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:40094 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749Ab3IEP0J convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 11:26:09 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFSv4: use mach cred for SECINFO_NO_NAME w/ integrity
Date: Thu, 5 Sep 2013 15:26:07 +0000
Message-ID: <F280C07A-314B-440A-995A-96198F36CE01@netapp.com>
References: <931669980.21.1378385417507.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <931669980.21.1378385417507.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 5, 2013, at 8:50 AM, Matt W. Benjamin <matt@linuxbox.com> wrote:

> Hi,
> 
> ----- "Dros Adamson" <Weston.Adamson@netapp.com> wrote:
> 
>> On Sep 4, 2013, at 12:29 PM, Matt W. Benjamin <matt@linuxbox.com>
>> wrote:
>> 
>>> Hi
>>> 
>>> It honestly feels quite odd to me for sec=sys to actually connote
>> krb5i.
>> 
>> I should point out that my patches don't introduce the use of krb5i
>> here, they just fix it.
> 
> Ack.
> 
>> 
>> I personally don't think it's weird for the client to use a *more*
>> secure flavor for certain (infrequent) operations when it makes sense.
>> What worries me that currently sec=krb5p can cross a SECINFO boundary
>> and suddenly be using sec=sys!
> 
> I think the behavior is obviously reasonable, but giving that policy a
> different name would allow sec=sys to continue mean what it says.    
> 

I think there is definitely room for discussion on how sec= behavior has changed and how this will affect users, especially when I add the patches mentioned below.

-dros

>> 
>> I'm testing patches that fix that now and also allow multiple sec=
>> options (in the same form as nfsd exports, i.e. sec=krb5:krb5i, but
>> I'm trying to fix all the recent regressions surrounding auth flavors
>> / SECINFO first...
> 
> That sounds great.
> 
>> 
>> -dros
>> 
>>> 
> 
> Thanks,
> 
> Matt
> 
> -- 
> Matt Benjamin
> The Linux Box
> 206 South Fifth Ave. Suite 150
> Ann Arbor, MI  48104
> 
> http://linuxbox.com
> 
> tel.  734-761-4689 
> fax.  734-769-8938 
> cel.  734-216-5309 

