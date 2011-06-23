Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38991 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932313Ab1FWUGQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 16:06:16 -0400
Received: by fxm17 with SMTP id 17so1479495fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2011 13:06:14 -0700 (PDT)
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20110623155947.GC8911@fieldses.org>
References: <20110622213209.GA3010@fieldses.org>
	<20110623155947.GC8911@fieldses.org>
Date: Thu, 23 Jun 2011 22:06:14 +0200
Message-ID: <BANLkTikS+Y-V=f3Pm8AF-AUoeYVo==4SzA@mail.gmail.com>
Subject: Re: autoload rpcsec_gss_krb5
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 23, 2011 at 5:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> By the way:
>
> On Wed, Jun 22, 2011 at 05:32:09PM -0400, J. Bruce Fields wrote:
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> index 0a9a2ec..5c33926 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> @@ -743,6 +743,13 @@ static struct pf_desc gss_kerberos_pfs[] = {
>>       },
>>  };
>>
>> +MODULE_ALIAS("rpc-auth-gss-krb5");
>> +MODULE_ALIAS("rpc-auth-gss-krb5i");
>> +MODULE_ALIAS("rpc-auth-gss-krb5p");
>> +MODULE_ALIAS("rpc-auth-gss-390003");
>> +MODULE_ALIAS("rpc-auth-gss-390004");
>> +MODULE_ALIAS("rpc-auth-gss-390005");
>
> Is there any reason we don't do this for the auth modules, and the pnfs
> layout modules?  Seems silly to wait for distro's to add it to
> modprobe.conf if we don't need to.
>

I recall a discussion at connectaton 2010, where Peter Staubach from
RedHat ( at that time )
requested a way to disable pNFS without rebuilding the kernel.

Probably that's why autoload is not implemented.

Regards,
   Tigran.

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
