From: sfaibish <sfaibish@emc.com>
Subject: Re: Performance results with exofs
Date: Mon, 07 Jun 2010 13:28:17 -0400
Message-ID: <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com>
References: <op.vdxrrgf1unckof@usensfaibisl2e.eng.emc.com> <4C0D195B.8030401@panasas.com> <4C0D1AAB.4070304@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"NFS list" <linux-nfs@vger.kernel.org>
To: "Boaz Harrosh" <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:59172 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab0FGR22 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 13:28:28 -0400
In-Reply-To: <4C0D1AAB.4070304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.

/Sorin

On Mon, 07 Jun 2010 12:13:31 -0400, Boaz Harrosh <bharrosh@panasas.com>=
 =20
wrote:

> On 06/07/2010 07:07 PM, Boaz Harrosh wrote:
>> On 06/07/2010 06:24 PM, sfaibish wrote:
>>> Boaz,
>>>
>>> You were mentioning some preliminary performance on NFS4.1 and pNFS=
 =20
>>> during
>>> the pNFS call few weeks back. I thought you put them in an email bu=
t I
>>> couldn't
>>> find that email. Could you re-send it to me or summarize the result=
s =20
>>> in a
>>> new
>>> email for comparison to the block layout performance. Bruce is also
>>> interested
>>> so I CC him as well. Thanks
>>>
>>> /Sorin
>>>
>>
>> I did not yet publish the Document. It's stuck behind my dis-talent =
for
>> writing and the pnfs bugs de jur.
>>
>> Basically all machines:
>> - connected by a 1 GBit link.
>> - All clients doing a dd write of 8GB file from /dev/zero
>> - 3of8 is the special raid-groups arrangement of exofs && objlayout
>>   where out of 8 devices each file is striped over 3 devices in a
>>   round robin fashion. (*With a small dirty trick)
>>
>
> - All tests over an *empty* filesystem.
>
>> [single client]
>> 1 - osds 40MB
>> 2 - osds 80MB
>> 4 - osds 114MB (saturation point of the 1 Gbit link)
>> 8 - osds 114MB
>>
>> [2 clients 8of8 osds]
>> 226 MBs
>>
>> [4 clients 8of8 osds]
>> 263 MBs
>>
>> [8 clients 8of8 osds]
>> 252 MBs
>>
>> [1 clients 3of8 osds]
>> 114 MBs
>>
>> [2 clients 3of8 osds *]
>> 226 MBs
>>
>> [4 clients 3of8 osds *]
>> 417 MBs
>>
>> [8 clients 3of8 osds]
>> 405 MBs
>>
>> Boaz
>>
>
>
>



--=20
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
