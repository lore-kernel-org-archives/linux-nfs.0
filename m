Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:25116 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751663AbdI1RaR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:17 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 0/8] NFSD support for "inter" server-to-server COPY
Date: Thu, 28 Sep 2017 13:29:54 -0400
Message-ID: <20170928173002.50818-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This depends on the async NFSD series and it depends on the client's
inter copy series that provide nfs4_ssc_open/close functions and
reboot recovery support for the destination server.

NFSD determines if COPY is intra or inter and if sync or async. For
inter, NSFD uses NFSv4.1 protocol and creates an internal mount point
(superblock). It will destroy the mount point when copy is done.

On the source server, upon receiving a COPY_NOTIFY, it generate a
unique stateid that's kept in the global list. Upon receiving a READ
with a stateid, the code checks the normal list of open stateid and
now additionally, it'll check the copy state list as well before
deciding to either fail with BAD_STATEID or find one that matches.
The stored stateid is only valid to be used for the first time
with a choosen lease period (90s currently). When the source server
received an OFFLOAD_CANCEL, it will remove the stateid from the
global list. Otherwise, the copy stateid is removed upon the removal
of its "parent" stateid (open/lock/delegation stateid).

v4:
* Don't have the IS_STALE_FH in the compount state structure. Instead
mark the filehandle FOREIGN. If the server gets a PUTFH,SAVEFH,PUTFH...
COPY compount then it'll allow for the PUTFH to be STALE (foreign)
handle. It 
* This series has Bruce's proposed "nfsd: remove unnecessary nofilehandle
checks" patch as I didn't see it committed yet.
* dropped the support for multiple server netaddrs in the COPY_NOTIFY/
COPY
* made sure to return OFFLOAD_DENIED when mount to the source server
fails which triggers the client to fallback on the traditional copy.

Andy Adamson (1):
  NFSD generalize nfsd4_compound_state flag names

Olga Kornievskaia (7):
  NFSD fill-in netloc4 structure
  NFSD add ca_source_server<> to COPY
  NFSD add COPY_NOTIFY operation
  NFSD check stateids against copy stateids
  nfsd: remove unnecessary nofilehandle checks
  NFSD: allow inter server COPY to have a STALE source server fh
  NFSD add nfs4 inter ssc to nfsd4_copy

 fs/nfsd/Kconfig      |  10 ++
 fs/nfsd/nfs4proc.c   | 427 ++++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c  |  37 ++++-
 fs/nfsd/nfs4xdr.c    | 168 +++++++++++++++++++-
 fs/nfsd/nfsd.h       |  31 +++-
 fs/nfsd/nfsfh.h      |   5 +-
 fs/nfsd/state.h      |   5 +-
 fs/nfsd/xdr4.h       |  25 ++-
 include/linux/nfs4.h |   1 +
 9 files changed, 657 insertions(+), 52 deletions(-)

-- 
1.8.3.1

