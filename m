From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Python scripts for analyzing NFS/RPC metrics
Date: Mon, 09 Jun 2008 12:47:21 -0400
Message-ID: <20080609163029.5461.35699.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26369 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbYFIQrs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 12:47:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

As promised, here are the Python scripts that I've implemented for analyzing
NFS and RPC performance metrics reported via /proc/self/mountstats.  They
still need man pages and proper installation in the nfs-utils Makefile.

While we decide whether to install and support these scripts as they are, or
to replace them with C language re-implementations, let's include them in
nfs-utils now so folks can try them out, bugs can be addressed, and missing
features provided.

---

Chuck Lever (2):
      Import the old iostat-ms Python script
      Import mountstats utility

Tom Talpey (2):
      NFS iostats - add RDMA statistics
      NFS mountstats - add RDMA statistics


 tools/mountstats/mountstats.py |  604 ++++++++++++++++++++++++++++++++++++++++
 tools/nfs-iostat/nfs-iostat.py |  564 +++++++++++++++++++++++++++++++++++++
 2 files changed, 1168 insertions(+), 0 deletions(-)
 create mode 100755 tools/mountstats/mountstats.py
 create mode 100755 tools/nfs-iostat/nfs-iostat.py

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
