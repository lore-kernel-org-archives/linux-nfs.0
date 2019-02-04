Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DC61C282CC
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:30:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2E0FF2083B
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:30:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="x3JKaDke";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="G85uSggS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725992AbfBDOak (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 09:30:40 -0500
Received: from wout2-smtp.messagingengine.com ([64.147.123.25]:57937 "EHLO
        wout2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728520AbfBDOaj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 09:30:39 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.west.internal (Postfix) with ESMTP id 6403F3001
        for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2019 09:30:36 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Mon, 04 Feb 2019 09:30:36 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=from
        :to:cc:subject:date:message-id:in-reply-to:references
        :mime-version:content-transfer-encoding; s=fm3; bh=CQHjECEP+dCcT
        V5k2qRzwix6WLYpFTjOHiPw+raa6zY=; b=x3JKaDkeqn8M7+sXFVWca02HxIB4C
        S5RZPHac9j6YKWkQUbZwF1gBMufwhfZZHYM7ey+7sshAy8XjY0/tKQk1Flcp3nBG
        bXGDbk/uwhiYZQLhyTo/0BmFAiKvSM3hkrV9f70ae85aq8qTZ8Yg/ErDu4fT3AGz
        yU7l4ARPVaE+U+O9q0sHjMkFaEcXmDaKK3lB5u8tOnGPOTFVauflTp1WKbPz5bn6
        zghGBqQMnH7PzE8F33XlkxY3lDvNmHBPTQHBG2uXLoXawAuYurxVWpsOoSmOryLr
        7fmJD11SvCVPVzCugpIAcicSVY8T995819GfPYOiBycybGxWJFT02j89Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:date:from
        :in-reply-to:message-id:mime-version:references:subject:to
        :x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
        fm1; bh=CQHjECEP+dCcTV5k2qRzwix6WLYpFTjOHiPw+raa6zY=; b=G85uSggS
        E4LHvJtfqN/KYgYHhUmRualAPJH8VNZizJ8t5orl6qZCKYsyTLlNsNFryK2mhYZG
        TtB6TfTTtwZ/Rg15pzsxyTwHTXPqTSEIwsgOChCSQc/FFxI6YQo6H13BlOcW3W2N
        qDi6XpUBBsJdrU4e7XtMPAGTOHEya/3bKwLj+ThyEhmqxncEULaMFqdRX5FAm8ZF
        g2zwKIk0HxI1vJZCXUpVeCvd31D58LtIAc/aSYswLQjjEmOadjkeC9LcGc4d0+MW
        PHmUcSIyyn3ly1ZWhF+hqtt7xcDu2rLvRw45bGKXxMWGmakAgdazgp5JFdXtYlh3
        /nEh4Y7Fbum9lQ==
X-ME-Sender: <xms:i0xYXKBHm4SgDmUJiTYDxuK8Tp-KWWInhvnqOlZfmvgQhVMtVwVShQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeeggdeiiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucenucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomheprf
    grthhrihgtkhcuufhtvghinhhhrghrughtuceophhssehpkhhsrdhimheqnecukfhppeej
    kedrheehrddvgeelrdeifeenucfrrghrrghmpehmrghilhhfrhhomhepphhssehpkhhsrd
    himhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:i0xYXOeELmEu2GcD97jVT_qz5BNsFs3mwcxIwDw7jIsNsEYOwuSKGw>
    <xmx:i0xYXPcpCRtobrGuXv73ZPB9eEXMWDW04z70iSAekLgOQFXkC0-oCA>
    <xmx:i0xYXENHVnYhWW3axiC9WNna9YEMlCQr5XdVKdwlS7E9wFzBplFmAQ>
    <xmx:i0xYXDrriVxPwBz5K1jLYmMcAKAX_pWi2DwuErvMncINxHUcHgYjBA>
Received: from NSJAIL (x4e37f93f.dyn.telefonica.de [78.55.249.63])
        by mail.messagingengine.com (Postfix) with ESMTPA id 5CEBE10310
        for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2019 09:30:35 -0500 (EST)
Received: from localhost (10.192.0.11 [10.192.0.11])
        by NSJAIL (OpenSMTPD) with ESMTPSA id 2919fab4 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO);
        Mon, 4 Feb 2019 14:30:32 +0000 (UTC)
From:   Patrick Steinhardt <ps@pks.im>
To:     linux-nfs@vger.kernel.org
Cc:     Patrick Steinhardt <ps@pks.im>
Subject: [PATCH 3/3] svc_socket: fix use of undefined macro HAVE_GETRPCBYNUMBER_R
Date:   Mon,  4 Feb 2019 15:31:20 +0100
Message-Id: <5e9826aa52e17d30d7cfee0d3828c5dbecdbfc41.1549290423.git.ps@pks.im>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The macro HAVE_GETRPCBYNUMBER_R is set based on whether the
`getrpcbynumber_r` function was found by autoconf or not. While another
location correctly checks whether it is set by using `#ifdef`,
`getservport()` instead wrongly uses `#if HAVE_GETRPCBYNUMBER_R`. This
may cause a compilation error with gcc with "-Werror=undef" if the macro
has not been defined.

Fix the error by using `#ifdef` instead.

Signed-off-by: Patrick Steinhardt <ps@pks.im>
---
 support/nfs/svc_socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index 1239712..d56507a 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -46,7 +46,7 @@ int getservport(u_long number, const char *proto)
 	struct rpcent *rpcp;
 	struct servent servbuf, *servp = NULL;
 	int ret = 0;
-#if HAVE_GETRPCBYNUMBER_R
+#ifdef HAVE_GETRPCBYNUMBER_R
 	char rpcdata[1024];
 	struct rpcent rpcbuf;
 
-- 
2.20.1

