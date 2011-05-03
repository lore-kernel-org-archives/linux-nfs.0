From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: Re: pNFS and ipv6
Date: Tue, 03 May 2011 17:51:15 +0200
Message-ID: <4DC02473.9000006@desy.de>
References: <4DC01F1A.9060305@desy.de> <D8F5F85C-06A1-4B93-8EDE-BA134488B616@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Dros Adamson <dros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-3.desy.de ([131.169.56.86]:51472 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab1ECPws (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 11:52:48 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 4EC6F1315
	for <linux-nfs@vger.kernel.org>; Tue,  3 May 2011 17:52:45 +0200 (MEST)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 408E712FA
	for <linux-nfs@vger.kernel.org>; Tue,  3 May 2011 17:52:45 +0200 (MEST)
In-Reply-To: <D8F5F85C-06A1-4B93-8EDE-BA134488B616@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Great! I am happy to test your patches,

Regards,
    Tigran.



On 05/03/2011 05:50 PM, Dros Adamson wrote:
> Yes, I'm actually working on that right now!
>
> -dros
>
> On May 3, 2011, at 11:28 AM, Tigran Mkrtchyan wrote:
>
>> Dear friends,
>>
>> are there plans to support IPv6 with pNFS ?
>>
>> fs/nfs/nfs4filelayoutdev.c:325
>>
>>         /* Currently only support ipv4 address */
>>         if (in4_pton(buf, rlen, (u8 *)&ip_addr, '-',&ipend) == 0) {
>>                 dprintk("%s: Only ipv4 addresses supported\n", __func__);
>>                 goto out_free;
>>         }
>>
>>
>> Regards,
>>    Tigran.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

