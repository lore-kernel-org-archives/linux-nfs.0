From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Subject: Re: starting 90-second grace period
Date: Fri, 11 Dec 2009 22:55:27 +0530
Message-ID: <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com>
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
	<1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:55002 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194AbZLKRZk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Dec 2009 12:25:40 -0500
Received: by iwn1 with SMTP id 1so586432iwn.33
        for <linux-nfs@vger.kernel.org>; Fri, 11 Dec 2009 09:25:47 -0800 (PST)
In-Reply-To: <1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

thankx a lot for the info.

btw, if i set nfs4leasetime to ~10 seconds ... is there any negative ef=
fect ?



On Fri, Dec 11, 2009 at 10:38 PM, Andy Adamson <andros@netapp.com> wrot=
e:
> you can set the lease time, which is the grace period, by writing to
>
> /proc/fs/nfsd/nfsv4leasetime
>
> note that this file is only available after the nfsd module is loaded=
, and
> is only read by nfsd upon startup.
>
> -->Andy
>
> On Dec 11, 2009, at 6:00 AM, Tharindu Rukshan Bamunuarachchi wrote:
>
>> hi all,
>>
>> Is there anyway to reduce or remove "90-second grace period" ?
>>
>> I could not find any configurable parameter.
>>
>> grace_time seems to be derived from user_lease_time & lease_time.
>>
>> what are the negative effects of changing *_lease_time ?
>>
>> cheers
>> --
>> Tharindu Rukshan Bamunuarachchi
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>



--=20
Tharindu Rukshan Bamunuarachchi
