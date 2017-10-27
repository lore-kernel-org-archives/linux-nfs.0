Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/2] Fix OPEN/CLOSE races
Date: Fri, 27 Oct 2017 16:18:27 -0400
Message-Id: <20171027201829.98702-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Patches to fix up the race between OPEN and CLOSE.

v2:
- Fix a sleep-while-atomic issue
- Clean up.    
- Add a tracepoint to help document wait incidents.
v3:
- Fix a state update issue

Trond Myklebust (2):
  NFSv4: Fix OPEN / CLOSE race
  NFSv4: Add a tracepoint to document open stateid updates

 fs/nfs/nfs4_fs.h   |   1 +
 fs/nfs/nfs4proc.c  | 135 +++++++++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4trace.h |   2 +
 3 files changed, 109 insertions(+), 29 deletions(-)

-- 
2.13.6
