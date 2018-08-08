Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mails1n0-route0.email.arizona.edu ([128.196.130.69]:6903 "EHLO
        mails1n0-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1729620AbeHHVcy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2018 17:32:54 -0400
Subject: Re: RDMA connection closed and not re-opened
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
 <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
 <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
 <0423D037-63F9-4BA6-882A-CBD9EBC630F2@oracle.com>
 <5b08ea1b-4cde-c432-92cc-04eff469ed54@genome.arizona.edu>
 <7F74B5E4-DCAD-46E1-988F-68E79FBD72FA@oracle.com>
 <51f7869c-de9a-65c3-9fd7-0133ca7232e1@genome.arizona.edu>
 <C5123ADC-2220-4C1C-B45E-0D9E16E9EFA7@oracle.com>
From: admin@genome.arizona.edu
Message-ID: <961e1f70-36bd-bfd2-eb3a-514c89b6cac6@genome.arizona.edu>
Date: Wed, 8 Aug 2018 12:11:37 -0700
MIME-Version: 1.0
In-Reply-To: <C5123ADC-2220-4C1C-B45E-0D9E16E9EFA7@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote on 08/08/2018 12:01 PM:
>> On Aug 8, 2018, at 2:54 PM, admin@genome.arizona.edu wrote:
>> Chuck Lever wrote on 07/14/2018 07:37 AM:
>>>> On Jul 13, 2018, at 6:32 PM, admin@genome.arizona.edu wrote:
>>>> Chuck Lever wrote on 07/13/2018 07:36 AM:
>>>>> You should be able to mount using "proto=tcp" with your mlx4 cards.
>>>>> That avoids the use of NFS/RDMA but would enable the use of the
>>>>> higher bandwidth network fabric.
>>>> Thanks I could definitely try that.  IPoIB has it's own set of issues though but can cross that bridge when I get to it....
>>> Stick with connected mode and keep rsize and wsize smaller
>>> than the IPoIB MTU, which can be set as high as 65KB.
>> We are running in this setup, so far so good... however the rsize/wsize were much greater than the IPoIB MTU, and it is probably causing these "page allocation failures" which fortunately have not been fatal; our computation is still running.  In the ifcfg file for the IPoIB interface, the MTU is set to 65520, which was the recommended maximum from the Red Hat manual.  So should rsize/wsize be set to 65519? or is it better to pick another value that is a multiple 1024 or something?
> 
> The r/wsize settings have to be power of two. The next power of
> two smaller than 65520 is 32768. Try "rsize=32768,wsize=32768" .

Thanks but what is the reason for that?  After googling around a while 
for rsize/wsize settings, i finally found in the nfs manual page (of all 
places!!) that "If a specified value is within the supported range but 
not a multiple of 1024, it is rounded down to the nearest multiple of 
1024."  So it sound like we could use 63KiB or 64512.
