From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] Updated pNFS Developmental kernel rpms
Date: Thu, 06 May 2010 22:37:53 +0300
Message-ID: <4BE31A91.3080200@panasas.com>
References: <4BDB417C.2090505@RedHat.com> <4BE31538.7010604@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:56712 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab0EFTiF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:38:05 -0400
Received: by wwb39 with SMTP id 39so278145wwb.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 12:38:02 -0700 (PDT)
In-Reply-To: <4BE31538.7010604-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 06, 2010, 22:15 +0300, Steve Dickson <SteveD@redhat.com> wrote:
> Please Note, I just added an pNFS enabled nfs-utils to these 
> repositories... This nfs-utils rpm should be usable on 
> all three Fedora versions... Please let me know
> if this is not the case...

Awesome. Thanks!

Benny

> 
> steved.
> 
> On 04/30/2010 04:45 PM, Steve Dickson wrote:
>> Hello,
>>
>> I've updated the Fedora pNFS development kernels to include 
>> the latest pNFS tag release and added new kernel repository. 
>>
>> The Fedora 13 kernels (kernel-2.6.33) were updated to
>> the pnfs-all-2.6.33-2010-04-29 git tag. I realize that F-13
>> distro is not yet fully released, but its close and with a little
>> a bit of persuasion ;-) and F-13 kernel can be used on a F-12 box. 
>>
>> I also added a Fedora devel (or rawhide) repository. This repository
>> will contain the Fedora Rawhide kernel (kernel-2.6.34) which
>> closely mirrors the mainstream kernel. This kernel was updated
>> to the pnfs-all-2.6.34-rc5-2010-04-29 git tag.
>>
>> There were no changes to the Fedora 12 (kernel-2.6.32) repository.
>>
>> Instructions on how to install and use these kernels are at:
>>
>> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
>> (Thank you Mark Uddin, from EMC, for your initial input on this,
>> the input was very helpful!)
>>  
>> If/when bugs are found with these rpms please enter them
>> in to the NFS Bugzilla Main Page at:
>>     https://bugzilla.linux-nfs.org/index.cgi
>>
>> Please use the "pNFS" keyword.. 
>>
>> Any question or issues please feel free to contact me... 
>>
>> steved.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

