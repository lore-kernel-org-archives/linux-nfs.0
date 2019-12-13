Return-Path: <SRS0=bIcc=2D=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6A8FC2D0D1
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Dec 2019 20:37:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E613024735
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Dec 2019 20:37:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727602AbfLMOLg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 13 Dec 2019 09:11:36 -0500
Received: from mout.kundenserver.de ([212.227.126.131]:36859 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727573AbfLMOLD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2019 09:11:03 -0500
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue009 [212.227.15.129]) with ESMTPA (Nemesis) id
 1Mi2BV-1i1js033dh-00e7iJ; Fri, 13 Dec 2019 15:10:57 +0100
From:   Arnd Bergmann <arnd@arndb.de>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        y2038@lists.linaro.org, Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 11/12] nfsd: use ktime_get_real_seconds() in nfs4_verifier
Date:   Fri, 13 Dec 2019 15:10:45 +0100
Message-Id: <20191213141046.1770441-12-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
In-Reply-To: <20191213141046.1770441-1-arnd@arndb.de>
References: <20191213141046.1770441-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:Pwg4ldcY+PirxuTk1NxKPR/wF0W7omnIpEhR4gWAXHpGQfencqU
 9EjmqFwbCPgYhBby6Q3tH+JCuKvm94AFXcEYbOtHvvBFf6t6QfakjHUFeX/9+wZ0WXOnnAf
 7Mj6sSgdq943phWuTRM8iA4/sHo+J04C+yauSKBDSHlxJ9ALUWqh/3hNXScfaod4Jm4H6EW
 TL/F8Z4OBfXWFGiYY0ojA==
X-UI-Out-Filterresults: notjunk:1;V03:K0:taJeJc826rg=:gsJimcb309nz2tjW+nHMfT
 GfN+0U2212OBpxgW7egoFIGQ862g/bQvkrGmWwk6BlCUv2H3GGv3fwNrtYdaW/Q+PjOJZmAJk
 +dK25vCWRztDD50tdguuWnRXx875Hn+wEVYv/6TkFFDaMqRqmNefb4exZPSbWpniFe/lCeZW4
 7B/FJM5yqkx3yVZvol7G4KSTp/totkFhFKDnr58T4mvRXNnqzhQeai5WL5hcA6AeONLwFSK6d
 iIQVqN/4hswZCeNX34EDDwDAKjreQA8NFkfUCLMOO7UBArxETkwq4GJqgh7Fnc6B6zSsrabv3
 HrrvQf0GEA1aVb/YDSqqfNhszpmPDG2YhJkrtc813TrR9WJfXCz46oNiJ8vdZ0KSODbvy3Pvn
 4SAgh0DX41V96BZuFQOxt6lAlkcjWyFoooimY6kte2bluDN1Fi5RnBjrDDjgtumWA0Yho2LEN
 H8J2vSmFqLDUI5yGWhnR9qw9aMPe/swv/fuTTNLztVdcTwoFtsxQTGcDQkgHEeawX2UvCL5Zo
 PQJpcU1Tqdhw6S/gbwImUkqrbfOdpL9InZWTE6UBmtlHX1VpUx/hprHP0MtW+D7gMfZz6J0S4
 SCRv1BGJLJMOEl18unsekpH0O56m+qfl+h2S4MX5IxxiMXeuLtz5qYWMpoRqypa0PQfa5LTtd
 HQybvMPDK334iImyClesbRDePlvRHikkYSfP2RYsvuRgjX77uAP23PrPk568aer4mRcsDM7wB
 rIeR6WDUn9NFERKrHVuW3Ke+/Sdszf16X9oA6Sf/kN2xVZYxQLKs2PG5VUepNbX1Apchz0nYz
 3PSpZK+XI5D/ctMMzt8O3Z6Lrvy2GNRKiDresjBT5jiAADMswqQkrvYa0GQkmC4ec3a++HXgJ
 8HHnwgNFBKTuyN4ERjSQ==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

gen_confirm() generates a unique identifier based on the current
time. This overflows in year 2038, but that is harmless since it
generally does not lead to duplicates, as long as the time has
been initialized by a real-time clock or NTP.

Using ktime_get_boottime_seconds() or ktime_get_seconds() would
avoid the overflow, but it would be more likely to result in
non-unique numbers.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6afdef63f6d7..efe3161f6cf7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2215,7 +2215,7 @@ static void gen_confirm(struct nfs4_client *clp, struct nfsd_net *nn)
 	 * This is opaque to client, so no need to byte-swap. Use
 	 * __force to keep sparse happy
 	 */
-	verf[0] = (__force __be32)get_seconds();
+	verf[0] = (__force __be32)(u32)ktime_get_real_seconds();
 	verf[1] = (__force __be32)nn->clverifier_counter++;
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
-- 
2.20.0

