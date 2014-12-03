Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34258 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbaLCTy7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2014 14:54:59 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so14446909ier.14
        for <linux-nfs@vger.kernel.org>; Wed, 03 Dec 2014 11:54:59 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 3 Dec 2014 14:54:59 -0500
Message-ID: <CAN-5tyFpbM5GE2fAcx8uMG6MO2JC-R4ASN_jrnmYH8idie_H+w@mail.gmail.com>
Subject: not picking a delegation stateid for IO when delegation stateid is
 being returned
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I would like an opinion about changing code in such as way that we
don't select a delegation stateid for an IO operation when this
particular delegation is being returned.

The reason it's some what problematic is that we send out a
DELEG_RETURN and then we don't remove the stateid until we receive a
reply. In the mean while, an IO operation can be happening and in
nfs4_select_rw_stateid() it sees a delegation stateid and uses it.
Well, at the server, it finishes processing DELEG_RETURN before
getting an IO op and by that time the server is finished with the
stateid and can error an IO operation with BAD_STATEID.

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7f3f606..4f6f6c9 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -854,7 +854,8 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid
*dst, struct inode *in
        flags &= FMODE_READ|FMODE_WRITE;
        rcu_read_lock();
        delegation = rcu_dereference(nfsi->delegation);
-       ret = (delegation != NULL && (delegation->type & flags) == flags);
+       ret = (delegation != NULL && (delegation->type & flags) == flags &&
+               !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags));
        if (ret) {
                nfs4_stateid_copy(dst, &delegation->stateid);
                nfs_mark_delegation_referenced(delegation);
