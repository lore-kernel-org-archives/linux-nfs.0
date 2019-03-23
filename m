Return-Path: <SRS0=9F0h=R2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 473DCC43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 02:44:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 18516218A2
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 02:44:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727982AbfCWCoS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Mar 2019 22:44:18 -0400
Received: from www262.sakura.ne.jp ([202.181.97.72]:40151 "EHLO
        www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727900AbfCWCoS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Mar 2019 22:44:18 -0400
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2N2iFYO088513;
        Sat, 23 Mar 2019 11:44:15 +0900 (JST)
        (envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Sat, 23 Mar 2019 11:44:15 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126094122116.bbtec.net [126.94.122.116])
        (authenticated bits=0)
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2N2iBSh088461
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
        Sat, 23 Mar 2019 11:44:15 +0900 (JST)
        (envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
To:     Kees Cook <keescook@chromium.org>
Cc:     Casey Schaufler <casey@schaufler-ca.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        LKML <linux-kernel@vger.kernel.org>
References: <20190315110555.0807d015@cakuba.netronome.com>
 <20190315120105.5541ad46@cakuba.netronome.com>
 <20190315165440.53b9db3c@cakuba.netronome.com>
 <CAGXu5jKHRPuaALQcPXvpDeuVgZR+EeRqo9Qj4j3kYatb3HUSSA@mail.gmail.com>
 <CAGXu5jL-e7bDEXfpUuT-HyFarR-8T0djXChR0cuzTwFQPQ0tOw@mail.gmail.com>
 <f23d0fad-dc72-0e53-cac6-31abfd12a050@I-love.SAKURA.ne.jp>
 <bee1a774-461a-2535-a640-bbe65291e909@schaufler-ca.com>
 <2bf23acd-22c4-a260-7648-845887a409d5@i-love.sakura.ne.jp>
 <CAGXu5jKj-Pq4krHmKd__4MoXBe1FK399cDZnSxdPigZo78tPfA@mail.gmail.com>
 <e20bf21e-77b0-6403-51b6-3f174d45529e@i-love.sakura.ne.jp>
 <CAGXu5jKVQ=-mdMWsefuNDagwF3pQEiosb4niRx-gBKCmRK_h-g@mail.gmail.com>
From:   Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <47335573-08f1-0efc-e51a-e2b6a6b69a01@i-love.sakura.ne.jp>
Date:   Sat, 23 Mar 2019 11:44:12 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKVQ=-mdMWsefuNDagwF3pQEiosb4niRx-gBKCmRK_h-g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/03/23 7:45, Kees Cook wrote:
> It breaks the backward-compat for the "security=" line. If a system is
> booted with CONFIG_LSM="minors...,apparmor" and "security=selinux",
> neither apparmor nor selinux will be initialized. The logic on
> "security=..." depends on the other LSMs being present in the list.

Really? The logic on "security=..." does not depend on LSM_FLAG_LEGACY_MAJOR
LSMs being present in the CONFIG_LSM= list, for ordered_lsm_parse() does

  (Step 1) Enable LSM_ORDER_FIRST module (i.e. capability).

  (Step 2) Disable LSM_FLAG_LEGACY_MAJOR modules which was not specified
           by "security=" parameter when "security=" parameter was specified.

  (Step 3) Enable modules specified by "lsm=" parameter (or CONFIG_LSM= settings
           if "lsm=" parameter was not specified).

  (Step 4) Enable up to one LSM_FLAG_LEGACY_MAJOR module which was specified
           by "security=" parameter when "security=" parameter was specified.

  (Step 5) Disable all unused modules.

and (Step 4) will compensate for lack of that module in (Step 3).
