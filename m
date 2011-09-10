Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61263 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758537Ab1IJHdy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Sep 2011 03:33:54 -0400
Received: by ywf7 with SMTP id 7so2239665ywf.19
        for <linux-nfs@vger.kernel.org>; Sat, 10 Sep 2011 00:33:54 -0700 (PDT)
Message-ID: <4E6B12DF.6050202@tonian.com>
Date: Sat, 10 Sep 2011 00:33:51 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>, "Rees, James" <rees@umich.edu>
Subject: pnfs-all-3.1-rc4-2011-09-10
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I rebased the linux-pnfs tree onto 3.1-rc4 plus Bruce's nfsd-2.6/for-3.2 patches
listed below.
I also merged Jim Rees's patches for the blocks layout driver
listed further below.

Benny

nfsd-devel:
da53586 nfsd4: Remove check for a 32-bit cookie in nfsd4_readdir()
6fa6aa0 nfsd4: fix seqid_mutating_error
0078363 nfsd4: return nfserr_symlink on v4 OPEN of non-regular file
73b3e9e locks: minor lease cleanup
699dbe0 locks: move F_INPROGRESS from fl_type to fl_flags field
7c2c9ac locks: fix tracking of inprogress lease breaks
6d151b1 locks: setlease cleanup
78ba69f sunrpc: use better NUMA affinities
79c3c2d nfsd4: clean up S_IS -> NF4 file type mapping
1e0019e nfsd: open-code special directory-hardlink check
c51d415 nfsd: clean up nfsd_mode_check()
e7cce0d nfsd4: fix incorrect comment in nfsd4_set_nfs4_acl
2d2a867 nfsd4: it's OK to return nfserr_symlink
96fa997 nfsd: remove unused defines
0eb4c2a Remove include/linux/nfsd/const.h
a27b69c nfsd4: permit read opens of executable-only files
38a5e64 nfsd: prettify NFSD_MAY_* flag definitions
c64404c nfsd4: simplify recovery dir setting
8587e1d nfsd4: fix failure to end nfsd4 grace period
c89cae6 nfsd4: stop using nfserr_resource for transitory errors
600244f nfsd4: replace some macros by functions
274bd38 nfsd4: name openowner data structures more clearly
69bcd00 nfsd4: cleanup lock/stateowner initialization
e96e1cc nfsd4: remove HAS_SESSION
59e4c26 nfsd4: cleanup and consolidate seqid_mutating_err
76f7342 nfsd4: simplify lock openmode check
054fa46 nfsd4: get lock checks out of preprocess_seqid_op
3a08abb nfsd4: remove redundant is_open_owner check
5ee87fc nfsd: remove include/linux/nfsd/syscall.h
777b7c1 nfsd4: fix off-by-one-error in SEQUENCE reply
23dd5f4 nfsd4: remove typoed replay field
4e761915 nfsd4: simplify distinguishing lock & open stateid's
b941293 nfsd4: consolidate lock & open stateid tables
d164bac nfsd4: simplify stateid generation code, fix wraparound
3e61992 nfsd4: make delegation stateid's seqid start at 1

pnfs-block:
6b99e7e pnfsblock: fix return code confusion
5232651 pnfsblock: fix size of upcall message

