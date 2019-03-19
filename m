Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F34E8C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 10:56:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C5CAD20857
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 10:56:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726717AbfCSK42 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 06:56:28 -0400
Received: from www262.sakura.ne.jp ([202.181.97.72]:39482 "EHLO
        www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726712AbfCSK42 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 06:56:28 -0400
Received: from fsav402.sakura.ne.jp (fsav402.sakura.ne.jp [133.242.250.101])
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2JAuPJR072932;
        Tue, 19 Mar 2019 19:56:25 +0900 (JST)
        (envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav402.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp);
 Tue, 19 Mar 2019 19:56:25 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126065253096.bbtec.net [126.65.253.96])
        (authenticated bits=0)
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2JAuIZn072901
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
        Tue, 19 Mar 2019 19:56:25 +0900 (JST)
        (envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
To:     Casey Schaufler <casey@schaufler-ca.com>,
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
 <bee1a774-461a-2535-a640-bbe65291e909@schaufler-ca.com>
From:   Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2bf23acd-22c4-a260-7648-845887a409d5@i-love.sakura.ne.jp>
Date:   Tue, 19 Mar 2019 19:56:15 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <bee1a774-461a-2535-a640-bbe65291e909@schaufler-ca.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since Kees Cook seems to be busy now, here is my version...

From 885553e4793d9af2d4e9e99c7d137b0ec7b5f8ad Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 19 Mar 2019 19:52:31 +0900
Subject: [PATCH] LSM: Revive CONFIG_DEFAULT_SECURITY_* for "make oldconfig"

Commit 70b62c25665f636c ("LoadPin: Initialize as ordered LSM") removed
CONFIG_DEFAULT_SECURITY_{SELINUX,SMACK,TOMOYO,APPARMOR,DAC} from
security/Kconfig and changed CONFIG_LSM to provide a fixed ordering as a
default value. That commit expected that existing users (upgrading from
Linux 5.0 and earlier) will edit CONFIG_LSM value in accordance with
their CONFIG_DEFAULT_SECURITY_* choice in their old kernel configs. But
since users might forget to edit CONFIG_LSM value, this patch revives
the choice (only for providing the default value for CONFIG_LSM) in order
to make sure that CONFIG_LSM reflects CONFIG_DEFAULT_SECURITY_* from their
old kernel configs.

Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 security/Kconfig | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/security/Kconfig b/security/Kconfig
index 1d6463f..743e594 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -239,9 +239,43 @@ source "security/safesetid/Kconfig"
 
 source "security/integrity/Kconfig"
 
+choice
+	prompt "Default security module [superseded by 'Ordered list of enabled LSMs' below]"
+	default DEFAULT_SECURITY_SELINUX if SECURITY_SELINUX
+	default DEFAULT_SECURITY_SMACK if SECURITY_SMACK
+	default DEFAULT_SECURITY_TOMOYO if SECURITY_TOMOYO
+	default DEFAULT_SECURITY_APPARMOR if SECURITY_APPARMOR
+	default DEFAULT_SECURITY_DAC
+
+	help
+	  This choice is there only for converting CONFIG_DEFAULT_SECURITY in old
+	  kernel config to CONFIG_LSM in new kernel config. Don't change this choice
+	  unless you are creating a fresh kernel config, for this choice will be
+	  ignored after CONFIG_LSM is once defined.
+
+	config DEFAULT_SECURITY_SELINUX
+		bool "SELinux" if SECURITY_SELINUX=y
+
+	config DEFAULT_SECURITY_SMACK
+		bool "Simplified Mandatory Access Control" if SECURITY_SMACK=y
+
+	config DEFAULT_SECURITY_TOMOYO
+		bool "TOMOYO" if SECURITY_TOMOYO=y
+
+	config DEFAULT_SECURITY_APPARMOR
+		bool "AppArmor" if SECURITY_APPARMOR=y
+	config DEFAULT_SECURITY_DAC
+		bool "Unix Discretionary Access Controls"
+
+endchoice
+
 config LSM
 	string "Ordered list of enabled LSMs"
-	default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
+	default "yama,loadpin,safesetid,integrity,selinux" if DEFAULT_SECURITY_SELINUX
+	default "yama,loadpin,safesetid,integrity,smack" if DEFAULT_SECURITY_SMACK
+	default "yama,loadpin,safesetid,integrity,tomoyo" if DEFAULT_SECURITY_TOMOYO
+	default "yama,loadpin,safesetid,integrity,apparmor" if DEFAULT_SECURITY_APPARMOR
+	default "yama,loadpin,safesetid,integrity"
 	help
 	  A comma-separated list of LSMs, in initialization order.
 	  Any LSMs left off this list will be ignored. This can be
-- 
1.8.3.1


