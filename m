Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91631C61DA4
	for <linux-nfs@archiver.kernel.org>; Sat, 11 Mar 2023 16:52:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229455AbjCKQwv convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 11 Mar 2023 11:52:51 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47524 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229502AbjCKQwu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Mar 2023 11:52:50 -0500
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C438519C40
        for <linux-nfs@vger.kernel.org>; Sat, 11 Mar 2023 08:52:47 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id A555B6431C24;
        Sat, 11 Mar 2023 17:52:45 +0100 (CET)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10032)
        with ESMTP id Cnu9RbTIOogw; Sat, 11 Mar 2023 17:52:45 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id 5D11D6431C2B;
        Sat, 11 Mar 2023 17:52:45 +0100 (CET)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id ZnxhikSFyl33; Sat, 11 Mar 2023 17:52:45 +0100 (CET)
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lithops.sigma-star.at (Postfix) with ESMTP id 2969F6431C24;
        Sat, 11 Mar 2023 17:52:45 +0100 (CET)
Date:   Sat, 11 Mar 2023 17:52:45 +0100 (CET)
From:   Richard Weinberger <richard@nod.at>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        trond myklebust <trond.myklebust@hammerspace.com>,
        chris chilvers <chris.chilvers@appsbroker.com>
Message-ID: <156604342.233758.1678553565027.JavaMail.zimbra@nod.at>
In-Reply-To: <655a8ee6-dd94-effd-738a-9ce8db8ebed7@redhat.com>
References: <1497292229.221220.1678287959937.JavaMail.zimbra@nod.at> <655a8ee6-dd94-effd-738a-9ce8db8ebed7@redhat.com>
Subject: Re: mountd: Possible bug in next_mnt()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-Originating-IP: [195.201.40.130]
X-Mailer: Zimbra 8.8.12_GA_3807 (ZimbraWebClient - FF97 (Linux)/8.8.12_GA_3809)
Thread-Topic: mountd: Possible bug in next_mnt()
Thread-Index: Adtc9++VxBBf3ZIymqYqL+RCZVMwTw==
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

----- Ursprüngliche Mail -----
>> next_mnt() finds submounts below a given path p.
>> While investigating into an issue in my crossmount patches for nfs-utils I
>> noticed
>> that it does not work when fsid=root, rootdir=/some/path/ and then "/" is being
>> exported.
>> In this case next_mnt() is asked to find submounts of "/" but returns none.
> I'm not clear as what you are saying... "rootdir=/some/path/" is not an
> export option.

Sorry for being imprecise.
rootdir= is an nfs.conf exports option.
 
Thanks,
//richard
