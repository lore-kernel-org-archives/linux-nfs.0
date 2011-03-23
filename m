Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:34140 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933043Ab1CWPc1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 11:32:27 -0400
Received: by qyg14 with SMTP id 14so7176780qyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 08:32:26 -0700 (PDT)
In-Reply-To: <20110323000925.GA6353@master.debian.org>
References: <AANLkTik72b2H3yVx7-YcE1Bmp73LboMzZ+DSOjww=RS0@mail.gmail.com>
	<20110323000925.GA6353@master.debian.org>
Date: Wed, 23 Mar 2011 11:32:26 -0400
Message-ID: <AANLkTimX=F3gk2_optA5pX315vpPARuP0DsgmBy0YXbO@mail.gmail.com>
Subject: Re: rpc.gssd: double free or corruption (was: libgssglue-0.2)
From: Kevin Coffman <kwc@citi.umich.edu>
To: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org,
        619052@bugs.debian.org, Tom Boven <tom.boven@telenet.be>,
        Bones <bones_was_here@yahoo.com.au>, Luk Claes <luk@debian.org>
Cc: =?ISO-8859-1?Q?An=EDbal_Monsalve_Salazar?= <anibal@debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/3/22 Aníbal Monsalve Salazar <anibal@debian.org>:
> On Wed, Mar 16, 2011 at 09:28:04PM -0400, Kevin Coffman wrote:
>>A new version of library libgssglue is now available from:
>>
>>http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.2.tar.gz
>>
>>Changes since libgssglue-0.1:
>>
>>       * Modify the gss_acquire_cred() code to accept, and
>>         properly handle, an input name of GSS_C_NO_NAME.
>>         Other misc. changes to support this change.
>>       * Remove some generated files from git.  Change
>>         autogen.sh to clean up files that might become
>>         outdated and incompatible.
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> Hello Kevin,
>
> Please have a look at Debian bug#619052.
>
> http://bugs.debian.org/619052
>
> The attached file is the original bug report.
>
> Thank you,
>
> Aníbal

Hi,
So far, I'm stumped.  I've been unable to reproduce this on my Fedora
13 machine.  I have a slightly different version of libc, an earlier
version of kerberos, and a later version of nfs-utils (the pnfs
version).  I went back to stock versions of everything and simply
replaced libgssglue with the new version.

glibc-2.12.2-1.x86_64
krb5-libs-1.7.1-17.fc13.x86_64
krb5-debuginfo-1.7.1-17.fc13.x86_64
krb5-auth-dialog-0.15-1.fc13.x86_64
krb5-workstation-1.7.1-17.fc13.x86_64
pam_krb5-2.3.11-1.fc13.x86_64
krb5-devel-1.7.1-17.fc13.x86_64
nfs-utils-lib-devel-1.1.5-1.fc13.x86_64
nfs-utils-1.2.3-2.pnfs.fc15.x86_64
nfs-utils-lib-1.1.5-1.fc13.x86_64
nfs-utils-lib-debuginfo-1.1.5-1.fc13.x86_64

Are you using any special options to gssd?

K.C.
