Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37362 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdGNUZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 16:25:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/5] skip op encoders in error cases
Date: Fri, 14 Jul 2017 16:24:50 -0400
Message-Id: <1500063895-29457-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is just some cleanup:

f961e3f2acae "nfsd: encoders mustn't use unitialized values in error
cases" fixed a couple cases like this:

	const struct nfsd4_layout_ops *ops =
                nfsd4_layout_ops[lgp->lg_layout_type];
        __be32 *p;

        dprintk("%s: err %d\n", __func__, nfserr);
        if (nfserr)
                goto out;

which ignored the fact that lg_layout_type isn't even initialized in
some error cases.

That seemed like an easy mistake to make, and made me wonder why we even
obther calling the xdr encoders in the error case, since almost all of
them are no-ops then.

So, these patches skip that.  I think it's an improvement, but I'll
listen to reason.

--b.

J. Bruce Fields (5):
  nfsd4: move some nfsd4 op definitions to xdr4.h
  opdesc will be useful outside nfs4proc.c
  nfsd4: define ->op_release for compound ops
  nfsd4: skip encoder in trivial error cases
  nfsd4: individual encoders no longer see error cases

 fs/nfsd/nfs4proc.c | 109 ++++++++----------
 fs/nfsd/nfs4xdr.c  | 322 ++++++++++++++++++-----------------------------------
 fs/nfsd/xdr4.h     |  49 ++++++++
 3 files changed, 208 insertions(+), 272 deletions(-)

-- 
2.9.4

