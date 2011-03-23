From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: rpc.gssd: double free or corruption (was: libgssglue-0.2)
Date: Tue, 22 Mar 2011 23:57:03 -0400
Message-ID: <AANLkTinTtQn41w8fKQrBKF6oZW=he=HZ3mx4ZKGRwN6p@mail.gmail.com>
References: <AANLkTik72b2H3yVx7-YcE1Bmp73LboMzZ+DSOjww=RS0@mail.gmail.com>
	<20110323000925.GA6353@master.debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?An=EDbal_Monsalve_Salazar?= <anibal@debian.org>
To: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org,
	619052@bugs.debian.org, Tom Boven <tom.boven-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org>,
	Bones <bones_was_here-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>, Luk Claes <luk@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:40699 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab1CWD5G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 23:57:06 -0400
Received: by qyg14 with SMTP id 14so6732907qyg.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 20:57:05 -0700 (PDT)
In-Reply-To: <20110323000925.GA6353-q3oZDYqQg6zyUObV3Cmqeti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/3/22 An=EDbal Monsalve Salazar <anibal@debian.org>:
> On Wed, Mar 16, 2011 at 09:28:04PM -0400, Kevin Coffman wrote:
>>A new version of library libgssglue is now available from:
>>
>>http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-=
0.2.tar.gz
>>
>>Changes since libgssglue-0.1:
>>
>> =A0 =A0 =A0 * Modify the gss_acquire_cred() code to accept, and
>> =A0 =A0 =A0 =A0 properly handle, an input name of GSS_C_NO_NAME.
>> =A0 =A0 =A0 =A0 Other misc. changes to support this change.
>> =A0 =A0 =A0 * Remove some generated files from git. =A0Change
>> =A0 =A0 =A0 =A0 autogen.sh to clean up files that might become
>> =A0 =A0 =A0 =A0 outdated and incompatible.
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
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
> An=EDbal
>

Thanks.  I will try to figure this out tomorrow.
