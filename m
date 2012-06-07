Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48090 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab2FGHrB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 03:47:01 -0400
MIME-Version: 1.0
Date: Thu, 7 Jun 2012 16:47:00 +0900
Message-ID: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
Subject: =?UTF-8?Q?Re=3A_Re=3A_Re=3A_=5BProblem=5DNFS_Server_=E2=80=93_Umount_results_i?=
	=?UTF-8?Q?n_Device_Busy=2E?=
From: Namjae Jeon <linkinjeon@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Cc: Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond.

As you know, Currently umount results in busy on NFS server although
user tried to succeed to umount on NFS client.
I suggest to add umount procedure to avoid umount busy issue.
When calling umount on NFS client, The resources(exportfs entries
cache) of mount point will be flushed on NFS server. and umount will
be succeed without busy issue.

how do you think about this suggestion ?

Thanks.

2012/5/11, AMIT SAHRAWAT <a.sahrawat@samsung.com>:
> Hi Bruce,
> Sorry it was the mail composer - I did not check mark the plain text
> option.
>
> We need an opinion.
> We will be using around 15 NFS client mounted - with one NFS Server. We are
> try to make out how many NFSD should we start at the NFS Server.
> It all depends upon the load - these 15 NFS clients are going to generate.
> But is there any default number - we should use to start with? like 1 per
> NFS client mount?
> Please share your advise on this.
>
> Thanks & Regards,
> Amit Sahrawat
>
> ------- Original Message -------
> Sender : J. Bruce Fields<bfields@fieldses.org>
> Date : May 10, 2012 17:46 (GMT+05:30)
> Title : Re: Re: [Problem]NFS Server – Um?ount results in Device Busy.
>
> On Thu, May 10, 2012 at 11:54:43AM +0000, AMIT SAHRAWAT wrote:
>>
>>
> Hi Bruce,
>
>>
>
>
>>
> Thanks for instant reply.
>
>
> Could you turn off html formatting on your mail?
>
>>
> The option you mentioned is working. 'exportfs -f'
>
>>
> Actually it is not mentioned anywhere - even when checked for options:
>
>>
> #> exportfs -h
> exportfs: invalid option -- 'h'
> usage: exportfs [-aruv] [host:/path]
>
>
>
> Sorry, it looks like the help test could be improved!  Patches
> welcomed....
>
> It is documented in the exportfs man page.
>
>>
> But - when tried to give - '-f' option it is working.
>
>>
> Then on checking the code for exportfs - got to know the working of '-f'
> option.
>
>>
> I think it should work. I will check with a number of scenario  - to check
> there is no blockage for other mount points - at the time 'exportfs -f' is
> being run. Please reply if it wont :)
>
>
> If no clients are using the export, it should work.
>
> --b.
>
>
>
> Thanks & Regards,
> Amit Sahrawat
