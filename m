Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35634 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab2HaGKK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2012 02:10:10 -0400
Received: by wgbdr13 with SMTP id dr13so2208308wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Aug 2012 23:10:08 -0700 (PDT)
Message-ID: <50405532.9070100@eneotecnologia.com>
Date: Fri, 31 Aug 2012 08:09:54 +0200
From: =?UTF-8?B?Q2FybG9zIEppbcOpbmV6?= <cjimenez@eneotecnologia.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Stale NFS file handle - persistent error
References: <503E131F.2040904@eneotecnologia.com> <503E13BF.6010304@eneotecnologia.com> <20120829171122.GA9983@fieldses.org> <503F0BEF.4020104@eneotecnologia.com> <503F8E7C.1030102@netapp.com> <20120830185937.GA23140@fieldses.org>
In-Reply-To: <20120830185937.GA23140@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, you are right.
Certainly, it is a very old kernel because we had problems with the SCSI 
controller in new distros with 2.6-3 kernel. I think there is another 
computer available, so I think the best choice will be to try to move to 
that one.

Thanks guys for your fast replies and your time.

Carlos.

On 08/30/2012 08:59 PM, J. Bruce Fields wrote:
> On Thu, Aug 30, 2012 at 12:02:04PM -0400, Bryan Schumaker wrote:
>> On 08/30/2012 02:45 AM, Carlos Jiménez wrote:
>>> Hi,
>>>
>>> Thank you for your reply.
>>>> Could you be more specific?  What kernel version exactly, and what
>>>> filesystem are you exporting, and what are the export options?
>>> Kernel version: 2.4.27-3-386
>> 2.4.27 is incredibly old, do you have access to the server and can you try a more recent kernel?
> Yes, we can't make much use of 2.4 bug reports at this point; you should
> probably report this to your distro, or try a more recent kernel.
>
> --b.
>
>> - Bryan
>>
>>> Filesystem exported: ext3
>>> Export options: rw,no_root_squash,sync
>>>
>>> I've shared/exported to the full network 192.168.180.0/24.
>>> The exported directory is /opt/virtual/one and in /opt/virtual it is mounted /dev/cciss/c0d0p4 (with default options), which is a 256GB (8GB used) partition over a 3 disks RAID5.
>>>
>>>> What version of NFS are you using?
>>>>
>>> Vers 3
>>>
>>>> I assume you're not doing anything else with either file or directory at
>>>> the same time?  (E.g., not deleting or renaming the file while it's
>>>> being copied?)
>>>>
>>>>
>>> I'm not doing anything else with either file or directory at the same time.
>>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

