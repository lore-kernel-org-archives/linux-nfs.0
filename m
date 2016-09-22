Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atlantic540.startdedicated.de ([188.138.9.77]:43955 "EHLO
        atlantic540.startdedicated.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753566AbcIVLy6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 07:54:58 -0400
From: Daniel Wagner <wagi@monom.org>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org,
        Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: [PATCH 0/2] NFS: Use complete() instead complete_all()
Date: Thu, 22 Sep 2016 13:54:27 +0200
Message-Id: <1474545269-8694-1-git-send-email-wagi@monom.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Hi,

Using complete_all() is not wrong per se but it suggest that there
might be more than one waiter. For -rt I am reviewing all
complete_all() users and would like to leave only the real ones in the
tree. The main problem for -rt about complete_all() is that it can be
uses inside IRQ context and that can lead to unbounded amount work
inside the interrupt handler. That is a no no for -rt.

Besides trying to analys all the code paths to the wait_for_completion()
call and convince myself that there is only one waiter, I also run
a few tests:

 - some fio benchmarks
 - pynfs
  -cthon04

Non of them exposed any blocking threads etc. pynfs did showed some
failures but I am guessing that is just missing implementation:

pynfs/nfs4.1/testserver.py random:/home/nfs-test --force -v all
 
EID50    st_exchange_id.testSSV                                   : FAILURE
           NFS4Error: OP_EXCHANGE_ID should return NFS4_OK,
           instead got NFS4ERR_ENCR_ALG_UNSUPP
LKPP1a   st_lookupp.testLink                                      : RUNNING
LKPP1a   st_lookupp.testLink                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_SYMLINK, instead got NFS4ERR_NOENT
LKPP1b   st_lookupp.testBlock                                     : RUNNING
LKPP1b   st_lookupp.testBlock                                     : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1c   st_lookupp.testChar                                      : RUNNING
LKPP1c   st_lookupp.testChar                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1d   st_lookupp.testLookupp                                   : RUNNING
LKPP1d   st_lookupp.testLookupp                                   : PASS
LKPP1f   st_lookupp.testFifo                                      : RUNNING
LKPP1f   st_lookupp.testFifo                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1r   st_lookupp.testFile                                      : RUNNING
LKPP1r   st_lookupp.testFile                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1s   st_lookupp.testSock                                      : RUNNING
LKPP1s   st_lookupp.testSock                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT


PUTFH1a  st_putfh.testLink                                        : RUNNING
PUTFH1a  st_putfh.testLink                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1b  st_putfh.testBlock                                       : RUNNING
PUTFH1b  st_putfh.testBlock                                       : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1c  st_putfh.testChar                                        : RUNNING
PUTFH1c  st_putfh.testChar                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1d  st_putfh.testDir                                         : RUNNING
PUTFH1d  st_putfh.testDir                                         : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1f  st_putfh.testFifo                                        : RUNNING
PUTFH1f  st_putfh.testFifo                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1r  st_putfh.testFile                                        : RUNNING
PUTFH1r  st_putfh.testFile                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1s  st_putfh.testSocket                                      : RUNNING
PUTFH1s  st_putfh.testSocket                                      : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT


RNM1b    st_rename.testValidBlock                                 : RUNNING
RNM1b    st_rename.testValidBlock                                 : FAILURE
           OP_CREATE should return NFS4_OK, instead got
           NFS4ERR_PERM
RNM1c    st_rename.testValidChar                                  : RUNNING
RNM1c    st_rename.testValidChar                                  : FAILURE
           OP_CREATE should return NFS4_OK, instead got
           NFS4ERR_PERM

RNM2a    st_rename.testSfhLink                                    : RUNNING
RNM2a    st_rename.testSfhLink                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2b    st_rename.testSfhBlock                                   : RUNNING
RNM2b    st_rename.testSfhBlock                                   : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2c    st_rename.testSfhChar                                    : RUNNING
RNM2c    st_rename.testSfhChar                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2f    st_rename.testSfhFifo                                    : RUNNING
RNM2f    st_rename.testSfhFifo                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2r    st_rename.testSfhFile                                    : RUNNING
RNM2r    st_rename.testSfhFile                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2s    st_rename.testSfhSocket                                  : RUNNING
RNM2s    st_rename.testSfhSocket                                  : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3a    st_rename.testCfhLink                                    : RUNNING
RNM3a    st_rename.testCfhLink                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3b    st_rename.testCfhBlock                                   : RUNNING
RNM3b    st_rename.testCfhBlock                                   : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3c    st_rename.testCfhChar                                    : RUNNING
RNM3c    st_rename.testCfhChar                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3f    st_rename.testCfhFifo                                    : RUNNING
RNM3f    st_rename.testCfhFifo                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3r    st_rename.testCfhFile                                    : RUNNING
RNM3r    st_rename.testCfhFile                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3s    st_rename.testCfhSocket                                  : RUNNING
RNM3s    st_rename.testCfhSocket                                  : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT

EID50    st_exchange_id.testSSV                                   : FAILURE
           NFS4Error: OP_EXCHANGE_ID should return NFS4_OK,
           instead got NFS4ERR_ENCR_ALG_UNSUPP
LKPP1a   st_lookupp.testLink                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_SYMLINK, instead got NFS4ERR_NOENT
LKPP1b   st_lookupp.testBlock                                     : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1c   st_lookupp.testChar                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT

LKPP1f   st_lookupp.testFifo                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1r   st_lookupp.testFile                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT
LKPP1s   st_lookupp.testSock                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_NOENT

PUTFH1a  st_putfh.testLink                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1b  st_putfh.testBlock                                       : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1c  st_putfh.testChar                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1d  st_putfh.testDir                                         : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1f  st_putfh.testFifo                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1r  st_putfh.testFile                                        : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
PUTFH1s  st_putfh.testSocket                                      : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT

RNM1b    st_rename.testValidBlock                                 : FAILURE
           OP_CREATE should return NFS4_OK, instead got
           NFS4ERR_PERM
RNM1c    st_rename.testValidChar                                  : FAILURE
           OP_CREATE should return NFS4_OK, instead got
           NFS4ERR_PERM

RNM2a    st_rename.testSfhLink                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2b    st_rename.testSfhBlock                                   : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2c    st_rename.testSfhChar                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2f    st_rename.testSfhFifo                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2r    st_rename.testSfhFile                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM2s    st_rename.testSfhSocket                                  : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3a    st_rename.testCfhLink                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3b    st_rename.testCfhBlock                                   : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3c    st_rename.testCfhChar                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3f    st_rename.testCfhFifo                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3r    st_rename.testCfhFile                                    : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT
RNM3s    st_rename.testCfhSocket                                  : FAILURE
           OP_LOOKUP should return NFS4_OK, instead got
           NFS4ERR_NOENT

VF1r     st_verify.testMandFile                                   : FAILURE

cheers,
daniel

Daniel Wagner (2):
  NFS: direct: use complete() instead of complete_all()
  NFS: cache_lib: use complete() instead of complete_all()

 fs/nfs/cache_lib.c | 2 +-
 fs/nfs/direct.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
2.7.4
