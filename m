Return-Path: <SRS0=ZwDk=DB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D86C4363D
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Sep 2020 17:41:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 532FA2399A
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Sep 2020 17:41:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728097AbgIXRlA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Sep 2020 13:41:00 -0400
Received: from smtprelay0075.hostedemail.com ([216.40.44.75]:44430 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726477AbgIXRlA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2020 13:41:00 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay08.hostedemail.com (Postfix) with ESMTP id 50DFF182CED2A;
        Thu, 24 Sep 2020 17:40:59 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: house52_2a01d1527160
X-Filterd-Recvd-Size: 3569
Received: from XPS-9350.home (unknown [47.151.133.149])
        (Authenticated sender: joe@perches.com)
        by omf04.hostedemail.com (Postfix) with ESMTPA;
        Thu, 24 Sep 2020 17:40:57 +0000 (UTC)
Message-ID: <ca629208707903da56823dd57540d677df2da283.camel@perches.com>
Subject: Re: [PATCH v3] nfs: remove incorrect fallthrough label
From:   Joe Perches <joe@perches.com>
To:     Nick Desaulniers <ndesaulniers@google.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc:     "Gustavo A . R . Silva" <gustavo@embeddedor.com>,
        "Gustavo A . R . Silva" <gustavoars@kernel.org>,
        Miaohe Lin <linmiaohe@huawei.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Hongxiang Lou <louhongxiang@huawei.com>,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        clang-built-linux <clang-built-linux@googlegroups.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mark Brown <broonie@kernel.org>
Date:   Thu, 24 Sep 2020 10:40:55 -0700
In-Reply-To: <CAKwvOdnziDJbRAP77K+V885SCuORfV4SmHDnSLUxhUGSSLMq_Q@mail.gmail.com>
References: <ce28bb9bc25cb3f1197f75950a0cfe14947f9002.camel@perches.com>
         <20200917214545.199463-1-ndesaulniers@google.com>
         <CAKwvOdnziDJbRAP77K+V885SCuORfV4SmHDnSLUxhUGSSLMq_Q@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.4-0ubuntu1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2020-09-24 at 10:19 -0700, Nick Desaulniers wrote:
> Hello maintainers,
> Would you mind please picking up this patch?  KernelCI has been
> erroring for over a week without it.

As it's trivial and necessary, why not go through Linus directly?

https://lore.kernel.org/patchwork/patch/1307549/

From: Nick Desaulniers <ndesaulniers@google.com>

There is no case after the default from which to fallthrough to. Clang
will error in this case (unhelpfully without context, see link below)
and GCC will with -Wswitch-unreachable.

The previous commit should have just replaced the comment with a break
statement.

If we consider implicit fallthrough to be a design mistake of C, then
all case statements should be terminated with one of the following
statements:
* break
* continue
* return
* fallthrough
* goto
* (call of function with __attribute__(__noreturn__))

Fixes: 2a1390c95a69 ("nfs: Convert to use the preferred fallthrough macro")
Link: https://bugs.llvm.org/show_bug.cgi?id=47539
Acked-by: Gustavo A. R. Silva <gustavoars@kernel.org>
Reviewed-by: Gustavo A. R. Silva <gustavoars@kernel.org>
Reviewed-by: Miaohe Lin <linmiaohe@huawei.com>
Reviewed-by: Nathan Chancellor <natechancellor@gmail.com>
Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
---
Changes v3:
* update the commit message as per Joe.
* collect tags.

Changes v2:
* add break rather than no terminating statement as per Joe.
* add Joe's suggested by tag.
* add blurb about acceptable terminal statements.

 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d20326ee0475..eb2401079b04 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -889,7 +889,7 @@  static struct nfs_server *nfs_try_mount_request(struct fs_context *fc)
 		default:
 			if (rpcauth_get_gssinfo(flavor, &info) != 0)
 				continue;
-			fallthrough;
+			break;
 		}
 		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
 		ctx->selected_flavor = flavor;

