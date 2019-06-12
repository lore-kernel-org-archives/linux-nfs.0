Return-Path: <SRS0=It5l=UL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC135C46477
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Jun 2019 12:11:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B67B820866
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Jun 2019 12:11:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OyAx8oEt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730892AbfFLMLB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Jun 2019 08:11:01 -0400
Received: from mail-pl1-f195.google.com ([209.85.214.195]:42160 "EHLO
        mail-pl1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727252AbfFLMLA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jun 2019 08:11:00 -0400
Received: by mail-pl1-f195.google.com with SMTP id go2so6548911plb.9;
        Wed, 12 Jun 2019 05:11:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=OcNe+Ykv8pNI9AsJnYaHIthvaQkPPzEoKbyDzZPPFUQ=;
        b=OyAx8oEtH/7qb7ZcfOcQCkmZIY6KpFzOsj2RUbbM46j9eGpnTEV7DhfEQgRk2QwnI6
         nhryKjE6BT1mG2qXheqyOuKXz1wg4wUmp3BKsthcyffnvQ2hHFKsFWZ5ybK9n3deGyK0
         Lgvd5LxDOJbuU5z/FjpUlX4RnSQ+ZM4m/GOUtqjJnXA+EHnd4QdCokj96nYOhTQ8Y12C
         As+NlACfpVgzbwLiE//O25sCnpgLWkhkfayVQkblkjAJH0btXcY0L/8hjmtLbvelL5Gd
         d6lQQ8HfujSdQVFllW7fHCXpfoYXTGSPAplA8sljcabbHssoVmVNSF5Mhq8hH2BEd+pi
         nyCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=OcNe+Ykv8pNI9AsJnYaHIthvaQkPPzEoKbyDzZPPFUQ=;
        b=dgBMPA5Ebvjh/uEC+1FcOIHG1JotvML7How5RJQ1j+x/sdksxHoSpp9JFDvcaMQV9C
         +duDH3ZCGwIbntu60zf2vCo6wv75ZruJhXXwEzwKn5pgGU2OJe0YTvbmcRkNsmxKxz3z
         7s6amFTfsoILZPjOg8keyz7qyVFCHSnh4+QUS7c9o/wKYWeVeDxj/DuJJP2MNLu+ofdr
         X6oSqSfSQEtz/a2rKScuP00jrqscnrwD97qZWWjo1dX7jOaIw+0Nu8GhQoloD0qQQi6v
         pxH1wszT9A7GdX8ThOuoN+N9Vz3/xGUYWtveO1YI6Apt9oDclyY4wyVjWq3b/xQi6XNu
         sFDQ==
X-Gm-Message-State: APjAAAUXQ9CQ83UWRhsz1FjmzUUAr0HEjGlisq+nRkBXTFjjZlsbiG7i
        zfCOMnYtTmLBVFMfbG/HUeo=
X-Google-Smtp-Source: APXvYqwEAEYrpAy3DKUJ4PFemUBZIB2HEUdg28z4c86rdecR/mAQ1vmRRjJTwNfNfGQH3ki7Uo4ggw==
X-Received: by 2002:a17:902:768b:: with SMTP id m11mr9693804pll.191.1560341459773;
        Wed, 12 Jun 2019 05:10:59 -0700 (PDT)
Received: from bridge.tencent.com ([119.28.31.106])
        by smtp.gmail.com with ESMTPSA id s5sm5035653pji.9.2019.06.12.05.10.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 05:10:59 -0700 (PDT)
From:   Wenbin Zeng <wenbin.zeng@gmail.com>
X-Google-Original-From: Wenbin Zeng <wenbinzeng@tencent.com>
To:     bfields@fieldses.org, davem@davemloft.net, viro@zeniv.linux.org.uk
Cc:     jlayton@kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, wenbinzeng@tencent.com,
        dsahern@gmail.com, nicolas.dichtel@6wind.com, willy@infradead.org,
        edumazet@google.com, jakub.kicinski@netronome.com,
        tyhicks@canonical.com, chuck.lever@oracle.com, neilb@suse.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH v3 3/3] auth_gss: fix deadlock that blocks rpcsec_gss_exit_net when use-gss-proxy==1
Date:   Wed, 12 Jun 2019 20:09:30 +0800
Message-Id: <1560341370-24197-4-git-send-email-wenbinzeng@tencent.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560341370-24197-1-git-send-email-wenbinzeng@tencent.com>
References: <1556692945-3996-1-git-send-email-wenbinzeng@tencent.com>
 <1560341370-24197-1-git-send-email-wenbinzeng@tencent.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When use-gss-proxy is set to 1, write_gssp() creates a rpc client in
gssp_rpc_create(), this increases netns refcount by 2, these refcounts are
supposed to be released in rpcsec_gss_exit_net(), but it will never happen
because rpcsec_gss_exit_net() is triggered only when netns refcount gets
to 0, specifically:
    refcount=0 -> cleanup_net() -> ops_exit_list -> rpcsec_gss_exit_net
It is a deadlock situation here, refcount will never get to 0 unless
rpcsec_gss_exit_net() is called.

This fix introduced a new callback i.e. evict in struct proc_ns_operations,
which is called in nsfs_evict. Moving rpcsec_gss_exit_net to evict path
gives it a chance to get called and avoids the above deadlock situation.

Signed-off-by: Wenbin Zeng <wenbinzeng@tencent.com>
Cc: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3fd56c0..3e76c8a 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2136,14 +2136,14 @@ static __net_init int rpcsec_gss_init_net(struct net *net)
 	return gss_svc_init_net(net);
 }
 
-static __net_exit void rpcsec_gss_exit_net(struct net *net)
+static void rpcsec_gss_evict_net(struct net *net)
 {
 	gss_svc_shutdown_net(net);
 }
 
 static struct pernet_operations rpcsec_gss_net_ops = {
 	.init = rpcsec_gss_init_net,
-	.exit = rpcsec_gss_exit_net,
+	.evict = rpcsec_gss_evict_net,
 };
 
 /*
-- 
1.8.3.1

