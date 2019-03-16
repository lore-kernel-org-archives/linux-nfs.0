Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF91C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 08:08:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7414C218E0
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 08:08:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726620AbfCPIIR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 04:08:17 -0400
Received: from www262.sakura.ne.jp ([202.181.97.72]:13984 "EHLO
        www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726551AbfCPIIR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2019 04:08:17 -0400
Received: from fsav403.sakura.ne.jp (fsav403.sakura.ne.jp [133.242.250.102])
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2G885FB073439;
        Sat, 16 Mar 2019 17:08:05 +0900 (JST)
        (envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav403.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp);
 Sat, 16 Mar 2019 17:08:05 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
        (authenticated bits=0)
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2G87xdd073418
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
        Sat, 16 Mar 2019 17:08:05 +0900 (JST)
        (envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
To:     Kees Cook <keescook@chromium.org>
Cc:     Jakub Kicinski <jakub.kicinski@netronome.com>,
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
From:   Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <f23d0fad-dc72-0e53-cac6-31abfd12a050@I-love.SAKURA.ne.jp>
Date:   Sat, 16 Mar 2019 17:08:02 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL-e7bDEXfpUuT-HyFarR-8T0djXChR0cuzTwFQPQ0tOw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/03/16 14:38, Kees Cook wrote:
>  config LSM
>         string "Ordered list of enabled LSMs"
> +       default "yama,loadpin,safesetid,integrity,smack,selinux,tomoyo,apparmor" if DEFAULT_SECURITY_SMACK
> +       default "yama,loadpin,safesetid,integrity,tomoyo,selinux,smack,apparmor" if DEFAULT_SECURITY_TOMOYO
> +       default "yama,loadpin,safesetid,integrity,apparmor,selinux,smack,tomoyo" if DEFAULT_SECURITY_APPARMOR
>         default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
>         help
>           A comma-separated list of LSMs, in initialization order.
> 
> (I don't see a way to include an earlier config string in a new
> default.) Thoughts?
>

Hmm, DEFAULT_SECURITY_TOMOYO no longer works because TOMOYO will be
always enabled as long as CONFIG_SECURITY_TOMOYO=y. Maybe

 config LSM
        string "Ordered list of enabled LSMs"
-       default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
+       default "yama,loadpin,safesetid,integrity,selinux" if DEFAULT_SECURITY_SELINUX
+       default "yama,loadpin,safesetid,integrity,smack" if DEFAULT_SECURITY_SMACK
+       default "yama,loadpin,safesetid,integrity,tomoyo" if DEFAULT_SECURITY_TOMOYO
+       default "yama,loadpin,safesetid,integrity,apparmor" if DEFAULT_SECURITY_APPARMOR
+       default "yama,loadpin,safesetid,integrity" if DEFAULT_SECURITY_DAC
        help
          A comma-separated list of LSMs, in initialization order.

(i.e. include only up to one major LSM as default choice, and allow manually including
multiple major LSMs at both kernel build time and kernel boot time) is better?

