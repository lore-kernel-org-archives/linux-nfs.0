Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f42.google.com ([209.85.215.42]:38642 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbbAUW3l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 17:29:41 -0500
Received: by mail-la0-f42.google.com with SMTP id ms9so20693547lab.1
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2015 14:29:40 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 21 Jan 2015 17:29:39 -0500
Message-ID: <CAN-5tyFX02eAzoO3NeRgBuyr8Hp0_xzaLNJ8BMJZ99gJqJmPMQ@mail.gmail.com>
Subject: race between inode eviction with delegation and opening same file
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a race between return of a delegation (due to resource
constraints and inode getting evicted) and an open for the same file
because….

In nfs_inode_return_delegation_noreclaim() we detach that delegation
from the inode first (nfs_inode_detach_delegation()) and then we send
a delegreturn. In between of nfs_inode_detach_delegation() and
nfs_do_return_delegation() an open request comes and it doesn’t see
any delegations for this inode and thus it sends an open request. At
the same time eviction thread is working on doing a delegreturn for
this inode. The server gets request for the open first and returns a
delegation for it (note: server will issue the same delegation stateid
but different seqnum as the one currently being returned by the
client). Then the server processes a delegreturn for this file (from
its perspective delegation stateid is no longer valid). Yet, on the
client side as it processes a reply from the server, it adds a “new”
delegation to the inode and proceeds to use it for an IO request later
which errors in BAD_STATEID.

I don't see how we can make detaching the delegation and the return of
it atomic. Instead I propose the following solution:
I propose to examine the delegation we get on open. If the sequence
number is not 0 and we don't have a delegation already then we must
have experienced this race. Therefore, we should return the delegation
(and ignore if this errors, as the server thinks there is no more
delegation). Something like this. Disclaimer: it doesn't seem to be
the actual fix (as it hangs the machine) so I'm still missing
something ....


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index b76166b..01bba63 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -368,5 +368,12 @@ int nfs_inode_set_delegation(struct inode *inode,
struct rpc_cred *cred, struct
                                old_delegation, clp);
                if (freeme == NULL)
                        goto out;
+       } else {
+               if (be32_to_cpu(delegation->stateid.seqid) > 0) {
+                       nfs_do_return_delegation(inode, delegation, 0);
+                       goto out;
+               }
        }
        list_add_rcu(&delegation->super_list, &server->delegations);
        nfsi->delegation_state = delegation->type;
