Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38311 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbcFTNmS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 09:42:18 -0400
Received: by mail-wm0-f53.google.com with SMTP id r201so62482563wme.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2016 06:41:41 -0700 (PDT)
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagigrim@gmail.com>
References: <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu>
 <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu>
 <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
 <57666E14.2070802@gmail.com>
 <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
 <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com>
 <20160620054453.GA1172@leon.nu>
Cc: leon@kernel.org, Or Gerlitz <gerlitz.or@gmail.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Majd Dibbiny <majd@mellanox.com>
From: Yishai Hadas <yishaih@dev.mellanox.co.il>
Message-ID: <12ee28bb-b838-ed4c-5f84-0cb8f1760d63@dev.mellanox.co.il>
Date: Mon, 20 Jun 2016 16:41:35 +0300
MIME-Version: 1.0
In-Reply-To: <20160620054453.GA1172@leon.nu>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/20/2016 8:44 AM, Leon Romanovsky wrote:
> On Sun, Jun 19, 2016 at 04:02:23PM -0400, Chuck Lever wrote:
>>
>
> Thanks Chuck and Sagi for the help.
>
> <...>
>
>>
>>> I
>>> didn't see such note along the thread, basically, I think this is
>>> where we should be starting, thoughts? I also added the mlx4 core/IB
>>> maintainer.
>>
>> Yishai was notified about this issue on May 25:
>>
>> http://marc.info/?l=linux-rdma&m=146419192913960&w=2
>
> Yishai and me follow this thread closely and we work on finding the
> root cause of this issue.
>

Just found the root cause of the problem, it was found to be a hardware 
limitation that is described as part of the PRM. The driver code had to 
be written accordingly, confirmed that internally with the relevant people.

 From PRM:
"The PBL should be physically contiguous, must reside in a 
64-byte-aligned address, and must not include the last 8 bytes of a page."

The last sentence pointed that only one page can be used as the last 8 
bytes should not be included. That's why there is a hard limit in the 
code for 511 entries.

Re the candidate fix that you sent, from initial review it makes sense, 
we'll formally confirm it soon after finalizing the regression testing 
in our side.

Thanks Chuck and Sagi for evaluating and working on a solution.
