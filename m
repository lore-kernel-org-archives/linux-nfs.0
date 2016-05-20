Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:40718 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645AbcETOoV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 May 2016 10:44:21 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 00/10] NFSV4.1,2 session trunking
Date: Fri, 20 May 2016 10:43:47 -0400
Message-ID: <1463755437-17649-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version-5
---------

Responded to Anna's code cleanup comments.

--> Andy

Version-4
---------

This patch set enables session trunking configured two ways.

The NFSv4 minorversion > 0 pseudo-fs is probed
with a GETATTR(fs_locations) to retrieve a replicas list.
Each replica address is tested for session trunking. Those
that pass are added as aliases to the mount rpc client.

Try all multipath addresses for a data server. The first address that
successfully connects and creates a session is the mount address.
All subsequent addresses are tested for session trunking and
added as aliases.

TODO:

- Periodically probe the pseudo-fs with the GETATTR(fs_locations)
to pick up server multipath changes. This is why the
GETATTR(fs_locations) is a stand alone call.

- Call BIND_CONN_TO_SESSION for session trunking addresses
established under SP4_MACH_CRED or SP4_SSV. SP4_NONE established
addresses do not require BIND_CONN_TO_SESSION.

TESTING:

The pseudo-fs GETATTR(fs_locations) probe session trunking
was tested against a Linux server with a pseudo-fs
export stanza (e.g. a stanza with the fsid=0 or fsid=root
export option) and a replicas= export option
(replicas=<path1>@<server1>:<path2>@<server2>..)
Note that this configuration is for testing only. A future
patchset will add the replicas= configuration to the
NFSEXP_V4ROOT nfsd and mountd processing.

The pNFS DS multipath session trunking was tested against a
pynfs server which provides DS multipath configuration.


Andy Adamson (10):
  NFS rename default callback ops
  NFS refactor nfs4_match_clientids
  NFS refactor nfs4_check_serverowner_major_id
  NFS detect session trunking
  NFS refactor _nfs4_proc_exchange_id for session trunking
  SUNRPC add flag to rpc_task_release_client
  NFS probe pseudo-fs for replicas
  NFS test and add multipaths for session trunking
  NFS test pnfs data server multipath session trunking aliases
  NFS add multiaddr to nfs_show_nfsv4_options

 fs/nfs/internal.h           |   2 +
 fs/nfs/nfs4_fs.h            |   9 ++
 fs/nfs/nfs4client.c         | 102 +++++++++++++++++---
 fs/nfs/nfs4getroot.c        |   3 +
 fs/nfs/nfs4proc.c           | 222 ++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c            |  38 +++-----
 fs/nfs/pnfs_nfs.c           |  51 +++++++---
 fs/nfs/super.c              |  26 ++++++
 include/linux/nfs_xdr.h     |   4 +-
 include/linux/sunrpc/clnt.h |   2 +-
 net/sunrpc/clnt.c           |   6 +-
 net/sunrpc/sched.c          |   2 +-
 net/sunrpc/xprtmultipath.c  |   4 +
 13 files changed, 406 insertions(+), 65 deletions(-)

-- 
1.8.3.1

