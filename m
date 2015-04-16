Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:38197 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347AbbDPP7z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Apr 2015 11:59:55 -0400
Message-ID: <552FDC79.8080606@fys.uio.no>
Date: Thu, 16 Apr 2015 17:59:53 +0200
From: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Problem installing nfs-utils to non standard dir
References: <552E3508.5000403@fys.uio.no> <552E86A8.6080506@gmail.com> <552E9D80.1090003@fys.uio.no> <552F3DE2.4020603@gmail.com> <552F8394.4070701@fys.uio.no> <552FAEEA.2090604@gmail.com> <552FC06E.2020204@fys.uio.no> <552FDAE8.9010208@gmail.com>
In-Reply-To: <552FDAE8.9010208@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hm, it seems to be there. ps output:

    26 root         0 SW<  [nfsiod]

Thanks,
Eino

On 04/16/2015 05:53 PM, Kinglong Mee wrote:
> On 4/16/2015 10:00 PM, Eino Juhani Oltedal wrote:
>> This is a very minimal linux install, it does not have firewalld.
>>
>> I think that this error might be caused by the kernel being built
>> without nfs support. I'm unsure how to test this without rebuilding the kernel, as I did not build it myself.
>>
>> I will try rebuilding the kernel tonight, to see if that helps.
> You can checking nfsiod process, "# ps -ajx | grep nfsiod",
> If it is exist, nfs is OK.
>
> thanks,
> Kinglong Mee
>   
>


