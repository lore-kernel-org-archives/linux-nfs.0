Return-Path: <SRS0=8+CZ=ST=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E53BFC10F12
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 09:22:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFB8E20835
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 09:22:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728143AbfDQJWw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Apr 2019 05:22:52 -0400
Received: from mx1.redhat.com ([209.132.183.28]:38096 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728108AbfDQJWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Apr 2019 05:22:51 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E0DBF3084212
        for <linux-nfs@vger.kernel.org>; Wed, 17 Apr 2019 09:22:51 +0000 (UTC)
Received: from yoyang-pc.usersys.redhat.com (dhcp-12-206.nay.redhat.com [10.66.12.206])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id C05D560148;
        Wed, 17 Apr 2019 09:22:50 +0000 (UTC)
Date:   Wed, 17 Apr 2019 17:22:47 +0800
From:   Yongcheng Yang <yongcheng.yang@gmail.com>
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: nfsidmap fail to build if no
 --with-pluginpath specified
Message-ID: <20190417092246.GA5865@yoyang-pc.usersys.redhat.com>
References: <20190402091651.17186-1-yongcheng.yang@gmail.com>
 <95e49187-6d99-4168-1bb1-4a3f6f2500ee@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <95e49187-6d99-4168-1bb1-4a3f6f2500ee@RedHat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 17 Apr 2019 09:22:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi SteveD,

On Tue, Apr 16, 2019 at 10:34:51AM -0400, Steve Dickson wrote:
> The only way I see a failure is when ./configure --with-pluginpath= 
> without a path which is wrong... 
> 
> ./configure --with-pluginpath=/usr/lib/libnfsidmap seems to work
> just fine
> 
> I thinking it is better to error out when a path is not given
> then to gloss over but used a default.
> 
> steved.
> 

From what you comments, there should be a plugin path assigned by
default if the user is not aware of it, correct?

Surely "./configure --with-pluginpath=/usr/lib/libnfsidmap" can work.
But I didn't know the specific exact path before.

I was just using "./configure" without any options and find out that
it's empty. (Please find my previous full logs)

Agree with you we should "use a default" one when path is not given.

Thanks,
Yongcheng
