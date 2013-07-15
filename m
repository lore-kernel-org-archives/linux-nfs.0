Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f41.google.com ([209.85.128.41]:57297 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288Ab3GOVWu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jul 2013 17:22:50 -0400
Message-ID: <51E46826.20709@gmail.com>
Date: Mon, 15 Jul 2013 17:22:46 -0400
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
To: "faibish, sorin" <faibish_sorin@emc.com>
CC: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>, xfs-oss <xfs@oss.sgi.com>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        device-mapper development <dm-devel@redhat.com>,
        IDE/ATA development list <linux-ide@vger.kernel.org>,
        "anaconda-devel-list@redhat.com" <anaconda-devel-list@redhat.com>
Subject: Re: Linux Plumbers IO & File System Micro-conference
References: <51E03AFB.1000000@gmail.com> <F0897B83F4BC10458936F08DADF233160F65F99416@MX02A.corp.emc.com>
In-Reply-To: <F0897B83F4BC10458936F08DADF233160F65F99416@MX02A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/2013 01:42 PM, faibish, sorin wrote:
> Can we have a discussion on Lustre client in the kernel? Thanks
>
> ./Sorin

I am not sure that we have that much to do for Lustre on the client side. Is 
this a topic that would be of broad enough interest to include people outside of 
the kernel developers?

thanks!

Ric

>
> -----Original Message-----
> From: linux-fsdevel-owner@vger.kernel.org [mailto:linux-fsdevel-owner@vger.kernel.org] On Behalf Of Ric Wheeler
> Sent: Friday, July 12, 2013 1:21 PM
> To: linux-scsi@vger.kernel.org; Linux FS Devel; linux-nfs@vger.kernel.org; linux-btrfs; xfs-oss; linux-ext4@vger.kernel.org; device-mapper development; IDE/ATA development list; anaconda-devel-list@redhat.com
> Subject: Linux Plumbers IO & File System Micro-conference
>
>
> Linux Plumbers has approved a file and storage microconference. The overview page is here:
>
> http://wiki.linuxplumbersconf.org/2013:file_and_storage_systems
>
> I would like to started gathering in ideas for topics. I have been approached already with a request to cover the copy_range work Zach Brown kicked off at LSF which I think is a great topic since it has impact throughout the stack, all the way up to applications programmers.
>
> A similar request was made to give some time to non-volatile memory devices and the proposed "persistent memory" backed block device and persistent memory file system from Intel. That also seems to fall in nicely with the plumbers mission statement since it clearly will impact everything from the application on down through the kernel.
>
> Last year, we had a good discussion on management of storage (anaconda, yast, libstoragemgt, etc) - that also might be worth giving updates on.
>
> The instructions for submitting ideas will be updated later today at:
>
> http://www.linuxplumbersconf.org/2013/submitting-topic/
>
> If you have topics that you would like to add, wait until the instructions get posted at the link above. If you are impatient, feel free to email me directly (but probably best to drop the broad mailing lists from the reply).
>
> Thanks!
>
> Ric
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

