Return-Path: <SRS0=IBSU=XA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DE6EC3A5A5
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Sep 2019 12:07:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2528921848
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Sep 2019 12:07:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732374AbfIEMHS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 5 Sep 2019 08:07:18 -0400
Received: from mx1.redhat.com ([209.132.183.28]:58294 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732003AbfIEMHS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Sep 2019 08:07:18 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5DED588382A;
        Thu,  5 Sep 2019 12:07:17 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-147.phx2.redhat.com [10.3.116.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9D1D76092F;
        Thu,  5 Sep 2019 12:07:15 +0000 (UTC)
Subject: Re: [PATCH 0/6] Fixes for various compiler warnings
To:     Patrick Steinhardt <ps@pks.im>, linux-nfs@vger.kernel.org
References: <cover.1566976047.git.ps@pks.im>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <765fec0d-c09f-d0b1-359f-b1d35e784315@RedHat.com>
Date:   Thu, 5 Sep 2019 08:07:15 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <cover.1566976047.git.ps@pks.im>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.69]); Thu, 05 Sep 2019 12:07:18 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 8/28/19 3:10 AM, Patrick Steinhardt wrote:
> Hi,
> 
> here's some assorted fixes for compiler warnings I'm seeing on my
> platform. Most warnings are probably due to using musl libc, but
> the fixes should be the correct thing to do regardless. With this
> patchset, I can now compile nfs-utils with -Werror just fine.
Patchset committed.... 

steved.
> 
> Regards
> Patrick
> 
> Patrick Steinhardt (6):
>   Annotate unused fields with UNUSED
>   Use <fcntl.h> header instead of <sys/fcntl.h>
>   Use <poll.h> header instead of <sys/poll.h>
>   configure.ac: Add <sys/socket.h> header when checking
>     sizeof(socklen_t)
>   nfsd_path: Include missing header for `struct stat`
>   mountd: Use unsigned for filesystem type magic constants
> 
>  configure.ac                   | 5 ++++-
>  support/export/xtab.c          | 2 +-
>  support/include/nfsd_path.h    | 2 ++
>  support/misc/xstat.c           | 3 ++-
>  support/nfs/rmtab.c            | 2 +-
>  support/nfs/rpc_socket.c       | 3 ++-
>  support/nfs/svc_socket.c       | 2 +-
>  support/nfs/xio.c              | 2 +-
>  utils/gssd/svcgssd_main_loop.c | 2 +-
>  utils/mountd/cache.c           | 4 ++--
>  utils/statd/sm-notify.c        | 2 +-
>  11 files changed, 18 insertions(+), 11 deletions(-)
> 
