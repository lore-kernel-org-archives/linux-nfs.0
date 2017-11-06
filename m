Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v8 11/11] NFSv4: Check the open stateid when searching for expired state
Date: Mon,  6 Nov 2017 15:28:11 -0500
Message-Id: <20171106202811.70202-12-trond.myklebust@primarydata.com>
In-Reply-To: <20171106202811.70202-11-trond.myklebust@primarydata.com>
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
 <20171106202811.70202-2-trond.myklebust@primarydata.com>
 <20171106202811.70202-3-trond.myklebust@primarydata.com>
 <20171106202811.70202-4-trond.myklebust@primarydata.com>
 <20171106202811.70202-5-trond.myklebust@primarydata.com>
 <20171106202811.70202-6-trond.myklebust@primarydata.com>
 <20171106202811.70202-7-trond.myklebust@primarydata.com>
 <20171106202811.70202-8-trond.myklebust@primarydata.com>
 <20171106202811.70202-9-trond.myklebust@primarydata.com>
 <20171106202811.70202-10-trond.myklebust@primarydata.com>
 <20171106202811.70202-11-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4a6f77880992..4415eda2ed35 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1431,6 +1431,11 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 			found = true;
 			continue;
 		}
+		if (nfs4_stateid_match_other(&state->open_stateid, stateid) &&
+		    nfs4_state_mark_reclaim_nograce(clp, state)) {
+			found = true;
+			continue;
+		}
 		if (nfs_state_lock_state_matches_stateid(state, stateid) &&
 		    nfs4_state_mark_reclaim_nograce(clp, state))
 			found = true;
-- 
2.13.6
