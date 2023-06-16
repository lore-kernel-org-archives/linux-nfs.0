Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01261EB64DA
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Jun 2023 13:20:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231286AbjFPNUL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Jun 2023 09:20:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59928 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1345617AbjFPNTw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2023 09:19:52 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1F5713589
        for <linux-nfs@vger.kernel.org>; Fri, 16 Jun 2023 06:19:48 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id AAEE76235A
        for <linux-nfs@vger.kernel.org>; Fri, 16 Jun 2023 13:19:47 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE497C433C8;
        Fri, 16 Jun 2023 13:19:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1686921586;
        bh=Q7Tdra7S9jPf1AOqObAsIz7dQp8aVPjmzP5SPTG2Ptc=;
        h=Subject:From:To:Cc:Date:From;
        b=EFckMy5FGxWKctbM5EjThW0Ut2BSoYRhugW27aw4ilijYSlFnDO2vdYH+N7a6BM8v
         YPxoWfHDlPeapHhmHcEiQ5OpeYJOdO6UUpMuovoj0GLS0qKXOI4gsF0r/hpDIcjF/u
         pGt+oLzZI/q5yKJ1ku2FT+uP968FbX/7a+qUcGrYRzY9SAEIOzEKPGi01EjFpVe0K5
         0dbj44yfuoW+VZ63Ae57TlsrdrfvhQi5EOrPYvSAgEMrsvWfynPe2x83FOwALwn+1p
         CrDOs1Mohf2KRhxDdfMKuCxoB2MSUHXXn07GrZnNfHreyTmT30M4BmOraZiXjSXNWP
         OQvROQ0z3DZgg==
Subject: [PATCH RFC] SUNRPC: Address sparse RCU warning in net/sunrpc/svc.c
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, paulmck@kernel.org
Date:   Fri, 16 Jun 2023 09:19:45 -0400
Message-ID: <168692158561.5365.6465796186839011597.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

$ make C=1 W=1 net/sunrpc/svc.o
make[1]: Entering directory '/home/cel/src/linux/obj/manet.1015granger.net'
  GEN     Makefile
  CALL    /home/cel/src/linux/server-development/scripts/checksyscalls.sh
  DESCEND objtool
  INSTALL libsubcmd_headers
  DESCEND bpf/resolve_btfids
  INSTALL libsubcmd_headers
  CC [M]  net/sunrpc/svc.o
  CHECK   /home/cel/src/linux/server-development/net/sunrpc/svc.c
/home/cel/src/linux/server-development/net/sunrpc/svc.c:1225:9: warning: incorrect type in argument 1 (different address spaces)
/home/cel/src/linux/server-development/net/sunrpc/svc.c:1225:9:    expected struct spinlock [usertype] *lock
/home/cel/src/linux/server-development/net/sunrpc/svc.c:1225:9:    got struct spinlock [noderef] __rcu *
/home/cel/src/linux/server-development/net/sunrpc/svc.c:1227:40: warning: incorrect type in argument 1 (different address spaces)
/home/cel/src/linux/server-development/net/sunrpc/svc.c:1227:40:    expected struct spinlock [usertype] *lock
/home/cel/src/linux/server-development/net/sunrpc/svc.c:1227:40:    got struct spinlock [noderef] __rcu *
make[1]: Leaving directory '/home/cel/src/linux/obj/manet.1015granger.net'

Warning introduced by commit 913292c97d75 ("sched.h: Annotate
sighand_struct with __rcu").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 79967b6925bd..174ebf2e36e1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1173,6 +1173,7 @@ static void __svc_unregister(struct net *net, const u32 program, const u32 versi
  */
 static void svc_unregister(const struct svc_serv *serv, struct net *net)
 {
+	struct sighand_struct *sighand;
 	struct svc_program *progp;
 	unsigned long flags;
 	unsigned int i;
@@ -1189,9 +1190,12 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 		}
 	}
 
-	spin_lock_irqsave(&current->sighand->siglock, flags);
+	rcu_read_lock();
+	sighand = rcu_dereference(current->sighand);
+	spin_lock_irqsave(&sighand->siglock, flags);
 	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
+	spin_unlock_irqrestore(&sighand->siglock, flags);
+	rcu_read_unlock();
 }
 
 /*


