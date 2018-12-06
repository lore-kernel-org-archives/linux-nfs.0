Return-Path: <SRS0=YXm+=OP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373B2C67838
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 15:11:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 051EF20700
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 15:11:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 051EF20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725871AbeLFPLB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 6 Dec 2018 10:11:01 -0500
Received: from mx1.redhat.com ([209.132.183.28]:46672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725862AbeLFPLB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Dec 2018 10:11:01 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CEF93307DAA4;
        Thu,  6 Dec 2018 15:11:00 +0000 (UTC)
Received: from localhost.localdomain (unknown [10.67.112.12])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 74384604DA;
        Thu,  6 Dec 2018 15:10:59 +0000 (UTC)
Subject: Re: NFS client behavior on WRITE_DELEGATION
To:     Anna Schumaker <schumakeranna@gmail.com>
Cc:     linux-nfs@vger.kernel.org, Matt Benjamin <mbenjamin@redhat.com>
References: <68c7c07a-949d-1ce0-ec7e-5ab71ffaaa3b@redhat.com>
 <CAFX2JfmYMnKoiQ0Kjt8SGLx2H=3GwwtLHco0wMR4xVHkJpLaoQ@mail.gmail.com>
From:   Soumya Koduri <skoduri@redhat.com>
Message-ID: <9ebd1b22-234c-f9ae-b3f8-015fe8e81a27@redhat.com>
Date:   Thu, 6 Dec 2018 20:40:57 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.0
MIME-Version: 1.0
In-Reply-To: <CAFX2JfmYMnKoiQ0Kjt8SGLx2H=3GwwtLHco0wMR4xVHkJpLaoQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 06 Dec 2018 15:11:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Anna,

Thanks a lot for the response. To understand client behavior under 
various scenarios, I started with a simple "C" program which does below 
operations in a loop on a nfsv4.1 mount point-

while(..)
{
OPEN,
LOCK,
READ/WRITE,
UNLCK,
CLOSE
}

While examining the pkt traces, I observed that even when granted 
WRITE_DELEGATION, there are WRITEs (though asynchronous & followed by 
COMMIT) sent to the server for each of those iterations. So could it be 
because of the kernel flushing out the data?

Also I noticed that the behavior of WRITE_DELEGATION granted for 
OPEN(O_RDWR) is different when compared to the one granted to OPEN(O_WRONLY)

1) When the file is opened with OPEN4_SHARE_ACCESS_WRITE and a 
OPEN_DELEGATE_WRITE delegation is granted, subsequent OPENs are avoided 
and not sent to the server as expected, whereas
If the file is opened with OPEN4_SHARE_ACCESS_BOTH and granted 
OPEN_DELEGATE_WRITE, the next open is sent to server resulting in server 
recalling the delegation it granted to the same client.

2) And to that recall request, client responded back with EBADHANDLE error.

This doesn't seem right. Could you please confirm.

(Maybe the server also can avoid conflicting the OPENfrom the same 
client to which it granted the delegation)

Thanks,
Soumya

On 12/6/18 1:52 AM, Anna Schumaker wrote:
> Hi Soumya,
> 
> What conditions are you seeing the writes?  It could be the kernel 
> trying to flush out data to free up memory for other processes.
> 
> I don't think preemptively writing back data is necessarily a bad thing 
> though, even with a write delegation.  If the server decides to recall 
> the delegation, we wouldn't keep it waiting as long while we write back 
> local data.  Additionally, if the client crashes then any updates might 
> have already had a chance to sync to the server.
> 
> I hope this helps!
> Anna
> 
> On Mon, Dec 3, 2018 at 2:55 AM Soumya Koduri <skoduri@redhat.com 
> <mailto:skoduri@redhat.com>> wrote:
> 
>     Hi,
> 
>     In our NFSv4.1 Delegations testing we observed that NFS client sends
>     WRITE requests to the server even when granted WRITE_DELEGATION. I see
>     that only OPEN/CLOSE and LOCK operations are served locally by the
>     client.
> 
>     Please confirm if this behavior is expected and if yes, can it be
>     improved to avoid sending WRITEs to the server until the application
>     does fsync.
> 
>     Thanks,
>     Soumya
> 
