Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/2] Fix OPEN/CLOSE races
Date: Mon, 30 Oct 2017 19:49:02 -0400
Message-Id: <20171030234904.17857-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

v2:
- Fix a sleep-while-atomic issue
- Clean up.    
- Add a tracepoint to help document wait incidents.
v3:
- Fix a state update issue
v3:
- Fix a race due to setting the state->flags before waiting on another
  compound (can cause issues if the other compound has an OPEN_DOWNGRADE).
- Fix stateid seqid wraparound.

Trond Myklebust (2):
  NFSv4: Fix OPEN / CLOSE race
  NFSv4: Add a tracepoint to document open stateid updates

 fs/nfs/nfs4_fs.h   |   1 +
 fs/nfs/nfs4proc.c  | 143 +++++++++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4trace.h |   2 +
 3 files changed, 114 insertions(+), 32 deletions(-)

-- 
2.13.6
