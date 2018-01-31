Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35021 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751728AbeAaFQ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 00:16:28 -0500
From: NeilBrown <neilb@suse.com>
To: David Howells <dhowells@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Date: Wed, 31 Jan 2018 16:15:39 +1100
Subject: [md PATCH 0/4] Minor 'cred' improvements prepare for NFS conversion
Cc: NFS <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
Message-ID: <151737571564.14845.2874586176125198504.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
 NFS and SUNRPC have an internal "rpc_cred" which plays two distinct
 roles, one of which is much the same as 'struct cred' (which didn't
 exist when rpc_cred was created).
 I want to replace that usage of rpc_cred with 'struct cred'.
 Doing so requires some minor improvements to cred.c and cred.h as
 follows.

 It isn't clear to me who "maintains" cred.c and cred.h, so I'm hoping
 that Andrew Morton will take these (if no-one complains).
 Alternately if I got one or two credible "Acked-by"s, they could go
 upstream through the NFS tree when the rest of the patches are ready.

Thanks,
NeilBrown


---

NeilBrown (4):
      cred: add cred_fscmp() for comparing creds.
      cred: add get_cred_rcu()
      cred: export get_task_cred().
      cred: allow get_cred() and put_cred() to be given NULL.


 include/linux/cred.h |   26 ++++++++++++++++++----
 kernel/cred.c        |   58 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 78 insertions(+), 6 deletions(-)

--
Signature

