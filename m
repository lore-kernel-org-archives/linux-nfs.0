From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Got error -10052 from the server on DESTROY_SESSION. Session
 has been destroyed regardless...
Date: Tue, 08 Jun 2010 19:39:43 +0300
Message-ID: <4C0E724F.7030908@panasas.com>
References: <4C0E6C37.3040504@panasas.com> <7A6A58246D5F0B4EA127BEA555B3A9AD079E5EA2@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "Sager, Mike" <Mike.Sager@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:55775 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755618Ab0FHQjq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 12:39:46 -0400
In-Reply-To: <7A6A58246D5F0B4EA127BEA555B3A9AD079E5EA2-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2010 07:36 PM, Sager, Mike wrote:
> Yes, I've seen this a lot...
> 
> Mike
> 

What versions? Are these on 2.6.35-rc2-pnfs only or 34-pnfs as well?

What is your setup pnfs-files nfs41 gfs2 ?

Thanks
Boaz

>> -----Original Message-----
>> From: Boaz Harrosh [mailto:bharrosh@panasas.com]
>> Sent: Tuesday, June 08, 2010 12:14 PM
>> To: NFS list
>> Subject: Got error -10052 from the server on DESTROY_SESSION. Session
>> has been destroyed regardless...
>>
>>
>> On 2.6.35-rc2-pnfs I get:
>>
>> Got error -10052 from the server on DESTROY_SESSION. Session has been
>> destroyed regardless...
>>
>> at end of cthon test. And it has hard time umounting. After some
>> seconds it is able to umount
>> Am investigating. Has any one seen this?
>>
>> Boaz
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

