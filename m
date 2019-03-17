Return-Path: <SRS0=3vgg=RU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 211E4C4360F
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Mar 2019 01:02:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DBBD9218D0
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Mar 2019 01:02:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="BdXYNVkz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726661AbfCQBCf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 21:02:35 -0400
Received: from sonic302-26.consmr.mail.ne1.yahoo.com ([66.163.186.152]:41201
        "EHLO sonic302-26.consmr.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726828AbfCQBCf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2019 21:02:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1552784553; bh=ZbzKoa4B6L0BfBgRjvRBW5sLUqTu697VSitRR2KIxZE=; h=Subject:To:Cc:References:From:Date:In-Reply-To:From:Subject; b=BdXYNVkznnAJDLudh9iBzZ1Hj8e3UXvCXIOxZ6/nHNGjvO2c7Y335XcREgdRbyd/6d7VvzXDs5DZR4lYNEwLcefHkhZA7oJt/o/MQ+bJ75S3lFa95KTz1wNcG2CCuugD2Wtng5L9APGdB4MWh19X5ieyvFG49+wbriLS6n0m1opSBQ4c0FQ+h655iCedZTnW2uQoTZ4T2nXDM79g7k6wGY3F05icorme6SvByOIb/7I9WjGnPi19Ck7IBBuXsOe/oBThgQUxW3x6CI5Xcfh6rVr8jNjZMScdHC/2CXAow18R87Eg4TKcNZNDncgvfepP+Zy5KXSE463ckb0b6Wjecw==
X-YMail-OSG: QlLBd44VM1nYy.QhrXjJqx_a2iwt6KVz7UsSzBVfNKSLnKvacL7OXk5LyuvV3Cm
 mDTu1cip6L_8xeAlo2PNFcuVQjUbCZbXa43vICaqLi.VqGID6Mlnb_H4IZUkOj41UAvIGJdxSNtG
 DwkX12Omw2FzGIKP7hIb9mKjmt5dcUN_B_8yjtCCatTXEGMB0O_i33apdiD.PDMRF4RYHlNLwshs
 GiJes4Hp_6IGled8BTQgWkRW7h2pZDwijxU9QbAham6nYpqWxVXHsWoAOzXXXPHzbPXSG_ctWaUs
 3u0ACinvfy8ZGcD1AT0rQAzN_pYVevBZfTHrRFiq12ndS1I6QR9PaefV5B1IRoneAa6wm_fU2bAn
 KdvNJJmDMWsvYGbOnIX37IKIabm3fHnDfjzL8rAkM59LFIxy4fq3Hd3W499AEo3qMp4P1afJ9sC0
 k.kgA1xtnB.vuU1rG03QqRjevaPeH3iiGpBEkBvPNb4SLoNrSf1liNviHF8U79RJqrIxN1oWf1d.
 Oi_PrBD0wmMsL3FGs8.u1uUQN1AjOHcXEivgtouXgp6oKnc6RT4m66R7UmgnWfl.NBc0Ds2jG1tE
 SEHAOzrLizi3zfzHN9h6tv6Wj8YajGeOwC4L5GK7aJXtLm6yDEXbpbzVwKrqN2pX.SJLkqMD24t5
 jHmFjW0Na8AW6CK3KUpctoGb_zg0_Y9z5WiJFLXvIGIVc.fpWqro2SRLHvObBLas0neGBsZnV5MX
 e_5QVjeH8Sg13E1CiegqLZf2RzWoooJaCNUHIwG7BVWTgdG_poIqqioZIIegkMTKOPAWZblpgiPa
 FILftBSS6.wihP2Qw1a_sVTETXKR8OqtRbPMOkHaQZzS9oYNbuaK83jRL5OmB0LaQIOjU0zcISwV
 nGZDoNsGJHukS.WfKblTfB9kN_2rvdG8dWJpksOE_LXZlRp07lXVHx0p.4HtKbiWYfA4ecAk9iew
 4jmTjQ87l3iWb44es.MDbAoWKhBd0ad_NJJldX.H2daAPGMmprAU0eHB75VWlMaQPUBvWsQj9knJ
 wS1lplr.eERCaaBBLGi7F2H0sm_oZHlMeJcn8adY2nWVgZU8Kx7LC8gwL1fVT2K0FK6X3k3zD6Ow
 x.oz2ugVFowmhpOjmej.y8xh8
Received: from sonic.gate.mail.ne1.yahoo.com by sonic302.consmr.mail.ne1.yahoo.com with HTTP; Sun, 17 Mar 2019 01:02:33 +0000
Received: from c-67-169-65-224.hsd1.ca.comcast.net (EHLO [192.168.0.103]) ([67.169.65.224])
          by smtp417.mail.ne1.yahoo.com (Oath Hermes SMTP Server) with ESMTPA ID 596d6594fead28a2b67ac524dc9c3831;
          Sun, 17 Mar 2019 01:02:32 +0000 (UTC)
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
To:     Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Kees Cook <keescook@chromium.org>
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
 <f23d0fad-dc72-0e53-cac6-31abfd12a050@I-love.SAKURA.ne.jp>
From:   Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <bee1a774-461a-2535-a640-bbe65291e909@schaufler-ca.com>
Date:   Sat, 16 Mar 2019 18:02:31 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <f23d0fad-dc72-0e53-cac6-31abfd12a050@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 3/16/2019 1:08 AM, Tetsuo Handa wrote:
> On 2019/03/16 14:38, Kees Cook wrote:
>>   config LSM
>>          string "Ordered list of enabled LSMs"
>> +       default "yama,loadpin,safesetid,integrity,smack,selinux,tomoyo,apparmor" if DEFAULT_SECURITY_SMACK
>> +       default "yama,loadpin,safesetid,integrity,tomoyo,selinux,smack,apparmor" if DEFAULT_SECURITY_TOMOYO
>> +       default "yama,loadpin,safesetid,integrity,apparmor,selinux,smack,tomoyo" if DEFAULT_SECURITY_APPARMOR
>>          default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
>>          help
>>            A comma-separated list of LSMs, in initialization order.
>>
>> (I don't see a way to include an earlier config string in a new
>> default.) Thoughts?
>>
> Hmm, DEFAULT_SECURITY_TOMOYO no longer works because TOMOYO will be
> always enabled as long as CONFIG_SECURITY_TOMOYO=y. Maybe
>
>   config LSM
>          string "Ordered list of enabled LSMs"
> -       default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
> +       default "yama,loadpin,safesetid,integrity,selinux" if DEFAULT_SECURITY_SELINUX
> +       default "yama,loadpin,safesetid,integrity,smack" if DEFAULT_SECURITY_SMACK
> +       default "yama,loadpin,safesetid,integrity,tomoyo" if DEFAULT_SECURITY_TOMOYO
> +       default "yama,loadpin,safesetid,integrity,apparmor" if DEFAULT_SECURITY_APPARMOR
> +       default "yama,loadpin,safesetid,integrity" if DEFAULT_SECURITY_DAC
>          help
>            A comma-separated list of LSMs, in initialization order.
>
> (i.e. include only up to one major LSM as default choice, and allow manually including
> multiple major LSMs at both kernel build time and kernel boot time) is better?

I think this looks pretty good.

