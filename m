Return-Path: <SRS0=31iP=RZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7CCAC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 14:07:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7DD2E21874
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 14:07:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727851AbfCVOHp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Mar 2019 10:07:45 -0400
Received: from mout.kundenserver.de ([212.227.17.10]:57969 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727487AbfCVOHp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Mar 2019 10:07:45 -0400
Received: from wuerfel.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.145]) with ESMTPA (Nemesis) id
 1M7KG2-1h42V92tcS-007ksc; Fri, 22 Mar 2019 15:07:27 +0100
From:   Arnd Bergmann <arnd@arndb.de>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc:     clang-built-linux@googlegroups.com,
        Nick Desaulniers <ndesaulniers@google.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Olga Kornievskaia <kolga@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: avoid uninitialized variable warning
Date:   Fri, 22 Mar 2019 15:07:11 +0100
Message-Id: <20190322140726.251521-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:ClqJeMIIUkB9B1PjxqSTgR+0icspArSydm3eP4QX8KXk1cbCgud
 iHZc7n3E2QXam7UFXOqaLr3HXM8LOTd2U4S7LTXrsyUQ54IFFxeDbvW/wtXsswAmsV1chi0
 rqN2cRIbaW05brr7QR9dDT9gfEABoxBc87eMuY2V9zIPfqKo7QcioQkfny3zfEzAphCtCdx
 qZEceoJdxr28tF3H6gXdg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:LGxE0xuTpZs=:kZtuMZP9gxBlOmbKB5g9TH
 OFD7INBA+zol0o63/lMsauA3ARhRDRKe8iidgyjakTWaeROQqoo4WthKNxy8TkmiD7C1QSItU
 zpgPnrPMXti9I0NaAIut0axtEdCxeqUWnft6q7Us2QzV5NUqHo6Eln0Ppn7HAwSJOuvrAux7r
 W9ZdBUts+/grU2oqWMenrL1UBI6rUT6pYeUG6SP4JYWkZr/dhr0ZsBqxZQAA5YNBotRlDBvuh
 ZZc6hPTj/GS3tHvKjKqyve5mzzfwUrx2okO+jfErbxnUCdsfaqm5+JLpyxDW6bWw4FkgXWnOW
 otRnhAql9DsHXcQOcG5ohL0Xi1MHhBwA4aSMY9QG4JqMBfBMn4uEUz9wy1ZlF+hvFUYZvTDFS
 H23fTdcH8V9ve0+QvPK8JDoLp/cJdCYKiAZ3nEWZ5pH/679+Y5FPJTzRnSq7/rAnA1QYno0GW
 M3VEvyxCN11JyY/A63WX9YK+LLZEH531ra5ivba9T3KuugxBoHXddlME1Ls8TuSk0jM1cKUB/
 xMcqGQvMaK2ite05Cm2jqB+MdbQpNz4aEOVw29R8as5RyBsBjKg86L3r5IRudm0EpmUy9xRMc
 2XDYTcVK+q+KY7SPPDFQ9enKRiVjdi7nrxdLwEBrSNxbM0PxbpX7IDIXILDLa6HF/rKnV4iBC
 ETN/0wccaoozGT3tF3ala1X9JpGlf0vwVClaOFCRx+KHAoV9Ot85S9azf/edJRUaegDNsn5qm
 lZtiklxc2ZKY82NW8RQgWG7iW8AMvftx7lb6PQ==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

clang warns that 'contextlen' may be accessed without an initialization:

fs/nfsd/nfs4xdr.c:2911:9: error: variable 'contextlen' is uninitialized when used here [-Werror,-Wuninitialized]
                                                                contextlen);
                                                                ^~~~~~~~~~
fs/nfsd/nfs4xdr.c:2424:16: note: initialize the variable 'contextlen' to silence this warning
        int contextlen;
                      ^
                       = 0

Presumably this cannot happen, as FATTR4_WORD2_SECURITY_LABEL is
set if CONFIG_NFSD_V4_SECURITY_LABEL is enabled.
Adding another #ifdef like the other two in this function
avoids the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/nfsd/nfs4xdr.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3de42a729093..a3a3455826aa 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2420,8 +2420,10 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 	__be32 status;
 	int err;
 	struct nfs4_acl *acl = NULL;
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 	void *context = NULL;
 	int contextlen;
+#endif
 	bool contextsupport = false;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	u32 minorversion = resp->cstate.minorversion;
@@ -2906,12 +2908,14 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			*p++ = cpu_to_be32(NFS4_CHANGE_TYPE_IS_TIME_METADATA);
 	}
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
 		status = nfsd4_encode_security_label(xdr, rqstp, context,
 								contextlen);
 		if (status)
 			goto out;
 	}
+#endif
 
 	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
 	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
-- 
2.20.0

