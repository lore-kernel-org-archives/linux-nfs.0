Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:15802 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759546Ab0FJRHw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 13:07:52 -0400
Date: Thu, 10 Jun 2010 13:07:42 -0400
To: "Benny Halevy" <bhalevy@panasas.com>
Subject: Re: Resent: [pnfs][PATCH 0/3] pnfs-blocklayout client: adding support for complex volume structure
From: sfaibish <sfaibish@emc.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
References: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com> <4C110849.8000500@panasas.com>
Message-ID: <op.vd3gi4n5unckof@usensfaibisl2e.eng.emc.com>
In-Reply-To: <4C110849.8000500@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 10 Jun 2010 11:44:09 -0400, Benny Halevy <bhalevy@panasas.com>  
wrote:

> On Jun. 04, 2010, 21:09 +0300, sfaibish <sfaibish@emc.com> wrote:
>> Apply against 2.6.34-rc3 pnfs branch. For pNFS client submission. Only
>> touches
>> the block layout driver.
>
> Sorin, I suggest you guys test this set with the linux-pnfs 2.6.35-rc2  
> tree
We already tested the patches and they work in our QA lab before we sent  
the
patches. We also tested in our labs in France. We used F13 as the base.

> against both the EMC and the spnfs-block server in the Ann Arbor
As I mentioned in the patch at this time the spnfs block server doesn't
support complex structures. After we get the pnfs client patches in the
git we will work to implement the complex volumes support in the spnfs
server. In principle the testing was done with EMC pnfs server and all
the cthon tests passed so this is what we would do at BAT anyways.
I have VM with the code so, if Bruce can have a VM client with the
patches we have the pnfs server of EMC in CITI lab.

> Bakeathon
> and resend.
Unfortunatelly, I will not be there and I am not sure if the new pNFS block
developer from CITI will be up to speed. I am busy with the next BAT
organization.

>
> I admit I didn't review this thoroughly yet and hopefully we can find  
> some
> time to do it together in Ann Arbor.
  :(

>
> Benny
>
>>
>> This patch set implements support for the complex volumes structures  
>> such
>> as
>> stripe of multiple volumes in a single metavolume and slice of  
>> metavolumes
>> into
>> smaller metavolumes. The patch set is specific to pnfs blocklayout and  
>> uses
>> simple rpc pipefs to generate messages that are passed to the userland
>> which is
>> using an daemon to discover all the devices in the message. The  
>> userspace
>> daemon
>> patches will be sent in a separate patch set.
>>
>> The patch set replaces the current single volume implementation of the
>> pnfs blocklayout
>> that has performance limitations and cannot support wide striped file
>> systems.
>> The wide stripe is imperious to the performance scalability both for
>> single and multiple
>> clients configurations. These patches address only the pnfs blocklayout
>> client. Similar
>> patches will be implemented for the pnfsd block layout served in the
>> second phase.
>>
>> 0001-pnfs-block-layout-add-simple-rpc-pipefs.patch
>> 0002-pnfs-block-layout-remove-device-creation-or-remove-from-kernel.patch
>> 0003-pnfs-block-layout-add-block-device-pipe-processing-based-on-simple-rpc.patch
>>
>> Testing:
>> CONFIG_NFS_V4_1 set:
>>
>> NFSv4.1/pNFS mounts:
>> Connectathon tests pass against Celerra/pNFS block layout server with  
>> both
>> simple
>> volumes and complex volumes stripe on 4 volumes and using a slice of  
>> half
>> of the
>> striped metavolume.
>>
>> CONFIG_NFS_V4_1 not set:
>> NFSv4.0 mount passes Connectathon tests.
>>
>> /Sorin
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC²
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
