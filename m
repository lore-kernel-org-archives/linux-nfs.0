Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B376BC65BAE
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 16:26:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 84B3E2086D
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 16:26:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84B3E2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727942AbeLMQ01 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 13 Dec 2018 11:26:27 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727815AbeLMQ01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Dec 2018 11:26:27 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7E0BD3082A26;
        Thu, 13 Dec 2018 16:26:27 +0000 (UTC)
Received: from localhost.localdomain (ovpn-124-181.rdu2.redhat.com [10.10.124.181])
        by smtp.corp.redhat.com (Postfix) with ESMTP id CBA601C94A;
        Thu, 13 Dec 2018 16:26:26 +0000 (UTC)
Reply-To: ffilz@redhat.com
Subject: Re: Handling of duplicate inode numbers for the directories in the
 nfs v3 kernel client
To:     Ashish Sangwan <ashishsangwan2@gmail.com>,
        linux-nfs@vger.kernel.org, neilb@suse.com
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
From:   Frank Filz <ffilz@redhat.com>
Organization: Red Hat
Message-ID: <09842ee0-9948-a5bd-a155-e0d6552b23bb@redhat.com>
Date:   Thu, 13 Dec 2018 08:26:26 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 13 Dec 2018 16:26:27 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 12/12/18 10:57 AM, Ashish Sangwan wrote:
> Hi,
>
> Our NFS filer can sometimes return same inode number for different directories.
> For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
> and dir4 might end up returning the same inode number to the client.
> Though it can never happen that inode numbers will be same for two
> directories and also there parent is same. Can linux client handle
> this case? What issues it can cause?
> https://lkml.org/lkml/2006/10/2/346
> I stumbled upon this thread where it is written that nfs client can
> handle this but userspace will see inode collisions. Given that this
> will happen only for directories, userspace utils logic might not get
> affected from this as hardlinks on directories are not possible. But
> the thread is really old. Wanted to confirm if this holds true even
> now.
>
> Thanks,
> Ashish

The find tool will detect the collisions and report them, and if I 
recall it stops proceeding down the directory tree from the duplicate 
inode number. I know for sure I've seen it complain, and pretty sure I 
saw it stop descending the tree into the directory with the duplicate 
inode number.


Frank

