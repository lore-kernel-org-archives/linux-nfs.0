Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA195C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 17:43:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A8C9A2082F
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 17:43:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8C9A2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731529AbeK1El5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 23:41:57 -0500
Received: from mx1.redhat.com ([209.132.183.28]:34944 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726288AbeK1El5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Nov 2018 23:41:57 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 02EF7811D3;
        Tue, 27 Nov 2018 17:43:18 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-124-225.rdu2.redhat.com [10.10.124.225])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 900E219747;
        Tue, 27 Nov 2018 17:43:17 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id 77FB1180365; Tue, 27 Nov 2018 12:43:16 -0500 (EST)
Date:   Tue, 27 Nov 2018 12:43:16 -0500
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     kernel test robot <rong.a.chen@intel.com>
Cc:     NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, lkp@01.org,
        linux-nfs@vger.kernel.org
Subject: Re: [LKP] [fs/locks]  83b381078b:  will-it-scale.per_thread_ops
 -62.5% regression
Message-ID: <20181127174315.GA29963@parsley.fieldses.org>
References: <20181127060102.GF6163@shao2-debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127060102.GF6163@shao2-debian>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 27 Nov 2018 17:43:18 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks for the report!

On Tue, Nov 27, 2018 at 02:01:02PM +0800, kernel test robot wrote:
> FYI, we noticed a -62.5% regression of will-it-scale.per_thread_ops due to commit:
> 
> 
> commit: 83b381078b5ecab098ebf6bc9548bb32af1dbf31 ("fs/locks: always delete_block after waiting.")
> https://git.kernel.org/cgit/linux/kernel/git/jlayton/linux.git locks-next
> 
> in testcase: will-it-scale
> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
> with following parameters:
> 
> 	nr_task: 16
> 	mode: thread
> 	test: lock1

So I guess it's doing this, uncontended file lock/unlock?:

	https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c

Each thread is repeatedly locking and unlocking a file that is only used
by that thread.

By the way, what's the X-axis on these graphs?  (Or the y-axis, for that
matter?)

--b.

>                             will-it-scale.per_thread_ops                        
>                                                                                 
>   450000 +-+----------------------------------------------------------------+   
>          |                                                                  |   
>   400000 +-+   +..+..  .+..+..  .+..+..+...+..+..+..   +..        .+..    ..|   
>   350000 +-+ ..      +.       +.                     ..         +.    +..+  |   
>          |  +                                       +     +     :           |   
>   300000 +-+                                              :    :            |   
>   250000 +-+                                               :   :            |   
>          |                                                 :   :            |   
>   200000 +-+                                               :   :            |   
>   150000 +-+                                                : :             |   
>          O  O  O  O  O  O  O  O  O  O  O   O  O  O  O  O  O :O: O  O  O  O  O   
>   100000 +-+                                                : :             |   
>    50000 +-+                                                : :             |   
>          |                                                   :              |   
>        0 +-+----------------------------------------------------------------+   
>                                                                                 
>                                                                                                                                                                 
>                                will-it-scale.workload                           
>                                                                                 
>   7e+06 +-+-----------------------------------------------------------------+   
>         |              +...+..           .+..+..+     +            +..      |   
>   6e+06 +-+   +..+.. ..         .+..+..+.        +   + +         ..       ..|   
>         |   ..      +         +.                  + +   +       +     +..+  |   
>   5e+06 +-++                                       +     +      :           |   
>         |                                                :     :            |   
>   4e+06 +-+                                               :    :            |   
>         |                                                 :    :            |   
>   3e+06 +-+                                                :   :            |   
>         |                                       O     O    :  : O  O        |   
>   2e+06 O-+O  O  O  O  O   O  O  O  O  O  O  O     O     O : O:       O  O  O   
>         |                                                   : :             |   
>   1e+06 +-+                                                 : :             |   
>         |                                                    :              |   
>       0 +-+-----------------------------------------------------------------+   
>                                                                                 
>                                                                                                                                                                 
>                            will-it-scale.time.user_time                         
>                                                                                 
>   250 +-+-------------------------------------------------------------------+   
>       |                 .+..               .+..                   +..       |   
>       |..   +...+..  .+.      .+...+..+..+.    +..    +..       ..   .    ..|   
>   200 +-+ ..       +.       +.                    . ..         +      +..+  |   
>       |  +                                         +     +     :            |   
>       |                                                  :    :             |   
>   150 +-+                                                 :   :             |   
>       |                                                   :   :             |   
>   100 +-+                                                 :   :             |   
>       |  O      O                                          : :              |   
>       O     O      O  O  O  O  O   O  O  O  O  O   O  O  O :O: O  O   O  O  O   
>    50 +-+                                                  : :              |   
>       |                                                    : :              |   
>       |                                                     :               |   
>     0 +-+-------------------------------------------------------------------+   
>                                                                                 
>                                                                                                                                                                 
>                           will-it-scale.time.system_time                        
>                                                                                 
>   5000 +-+------------------------------------------------------------------+   
>   4500 O-+O..O..O...O..O..O..O..O..O..O...O..O..O..O..O..O  O  O...O..O..O..O   
>        |                                                 :     :            |   
>   4000 +-+                                               :     :            |   
>   3500 +-+                                                :   :             |   
>        |                                                  :   :             |   
>   3000 +-+                                                :   :             |   
>   2500 +-+                                                :   :             |   
>   2000 +-+                                                 : :              |   
>        |                                                   : :              |   
>   1500 +-+                                                 : :              |   
>   1000 +-+                                                 : :              |   
>        |                                                    :               |   
>    500 +-+                                                  :               |   
>      0 +-+------------------------------------------------------------------+   
>                                                                                 
>                                                                                 
> [*] bisect-good sample
> [O] bisect-bad  sample
