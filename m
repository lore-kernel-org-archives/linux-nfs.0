Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753444AbdJTRry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 13:47:54 -0400
Date: Fri, 20 Oct 2017 13:47:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsd4: fix cached replies to solo SEQUENCE compounds
Message-ID: <20171020174747.GC31637@parsley.fieldses.org>
References: <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
 <1508361919-30495-1-git-send-email-bfields@redhat.com>
 <CAN-5tyHBv9iFfTEPTgCfNyBo9veiqWiD_2xzVwhHjQ_tNdMFZw@mail.gmail.com>
 <20171019181718.GF16942@parsley.fieldses.org>
 <CAN-5tyFCBrfLnw91R5awik6+miCO7vGfB-K40D1yQw-+nJ6eiQ@mail.gmail.com>
 <20171019202015.GG16942@parsley.fieldses.org>
 <CAN-5tyHQUB0x1YhdMosM1pg12kuK9gEeqW2ruufxfFsPLHL_Ew@mail.gmail.com>
 <CAN-5tyGb9EuYH90LLdDDNZJHWs3RPxK6FvjneKFsM4Yao=Vk0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGb9EuYH90LLdDDNZJHWs3RPxK6FvjneKFsM4Yao=Vk0g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 05:19:40PM -0400, Olga Kornievskaia wrote:
> On Thu, Oct 19, 2017 at 5:04 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > I got this crash upon receiving the SEQUENCE that reused the slot that
> > was used by the ctrl-c-ed COPY.

Yeah, I was being inconsistent about what "NFSD4_SLOT_CACHED" meant--in
replay_matches_cache I'm assuming opcnt and cred are still stored, but I
wasn't storing them in nfsd4_store_cache_entry.  Not sure why that
didn't triger in my tests.

Does this help?

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ace89bf45a0b..4b2107d11d5e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2296,14 +2296,15 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
 	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
 	free_svc_cred(&slot->sl_cred);
+	copy_cred(&slot->sl_cred, &resp->rqstp->rq_cred);
+	slot->sl_opcnt = resp->opcnt;
+	slot->sl_status = resp->cstate.status;
+
 	if (!nfsd4_cache_this(resp)) {
 		slot->sl_flags &= ~NFSD4_SLOT_CACHED;
 		return;
 	}
 	slot->sl_flags |= NFSD4_SLOT_CACHED;
-	copy_cred(&slot->sl_cred, &resp->rqstp->rq_cred);
-	slot->sl_opcnt = resp->opcnt;
-	slot->sl_status = resp->cstate.status;
 
 	base = resp->cstate.data_offset;
 	slot->sl_datalen = buf->len - base;
