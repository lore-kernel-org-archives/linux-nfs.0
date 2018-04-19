Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:46388 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbeDSPLG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2018 11:11:06 -0400
Received: by mail-ua0-f196.google.com with SMTP id a17so3643794uaf.13
        for <linux-nfs@vger.kernel.org>; Thu, 19 Apr 2018 08:11:05 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 19 Apr 2018 11:11:04 -0400
Message-ID: <CAN-5tyEYLdK-reaDNrGY33jRxDuT9aSvqS_d3ERYBpSNkOUnLA@mail.gmail.com>
Subject: understanding the need for 2 SETCLIENTIDs on the client
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I'd like to understand the need for doing a double SETCLIENTID by the
client. Initial mount calls nfs4_init_client() which initiates
trunking discovery and calls nfs40_discover_client_trunking() which
ends up sending the SETCLIENTID to the server. However, then on the
first open, the client calls _nfs4_do_open() which calls
nfs4_client_recover_expired_lease() which checks the flags and finds
NFS4CLNT_LEASE_EXPIRED set which triggers another SETCLIENTID.

Client is created in nfs4_alloc_client() with cl_flags having
NFS4CLNT_LEASE_EXPIRED. But why doesn't a successful SETCLIENTID clear
the LEASE_EXPIRED?

If we were to clear the LEASE_EXPIRED flag (which seems like the right
thing after establishing a valid clientid), then open would find a
non-expired state.

Thoughts?

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 9796314..9ad6110 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -581,6 +581,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
                        nfs4_swap_callback_idents(pos, new);
                        pos->cl_confirm = new->cl_confirm;
                        nfs_mark_client_ready(pos, NFS_CS_READY);
+                       clear_bit(NFS4CLNT_LEASE_EXPIRED, &pos->cl_state);

                        prev = NULL;
                        *result = pos;
