Return-Path: <SRS0=fB6X=RY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5570EC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 21:10:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2BFB921916
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 21:10:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726555AbfCUVKW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Mar 2019 17:10:22 -0400
Received: from www262.sakura.ne.jp ([202.181.97.72]:62612 "EHLO
        www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726093AbfCUVKW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2019 17:10:22 -0400
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2LLAJPi091816;
        Fri, 22 Mar 2019 06:10:19 +0900 (JST)
        (envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Fri, 22 Mar 2019 06:10:19 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126094122116.bbtec.net [126.94.122.116])
        (authenticated bits=0)
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2LLAEL3091793
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
        Fri, 22 Mar 2019 06:10:19 +0900 (JST)
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
From:   Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <e20bf21e-77b0-6403-51b6-3f174d45529e@i-love.sakura.ne.jp>
Date:   Fri, 22 Mar 2019 06:10:14 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKj-Pq4krHmKd__4MoXBe1FK399cDZnSxdPigZo78tPfA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/03/22 1:38, Kees Cook wrote:
> This is mostly good. I'd like to keep the other LSMs listed though
> (similar to what I had originally) so that if a legacy-major doesn't
> initialize, later ones will be. I want to remove the concept of
> "major" LSMs. The only thing that should matter is init order...

Excuse me? Are you saying that

  if a legacy-major (which is defined as the "Default security module")
  doesn't initialize, later ones (any of selinux,smack,tomoyo,apparmor
  except the one which is defined as "Default security module") will be
  initialized

? That sounds strange to me. Any of selinux,smack,tomoyo,apparmor can be
initialized when specified by lsm= kernel command line option (or security=
kernel command line option if lsm= kernel command line option is not
specified), won't it?

