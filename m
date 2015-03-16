Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:44147 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbbCPVSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 17:18:11 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 0/3] NFSD: Add READ_PLUS support
Date: Mon, 16 Mar 2015 17:18:05 -0400
Message-ID: <1426540688-32095-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add server support for the NFS v4.2 operation READ_PLUS.

I tested these patches using xfstests and compared the runtime between NFS
v4.1, NFS v4.2 without READ_PLUS, and NFS v4.2 with READ_PLUS.  Here are
the results:


   Test     |   v4.1    | no READ_PLUS |  READ_PLUS
---------------------------------------------------
generic/013 | 135s      |    143s      |    123s
generic/075 |   4s      |     11s      |      4s
generic/091 |   9s      |     16s      |     15s
generic/112 |   4s      |      7s      |      6s
generic/127 |  62s      |    117s      |    114s
generic/213 | [not run] |      1s      |      1s
generic/214 | [not run] |      0s      |      0s
generic/228 | [not run] |      1s      |      2s
generic/236 |   1s      |      1s      |      1s
generic/263 |   4s      |      6s      |      8s
generic/285 |   0s      |      1s      |      3s
generic/315 | [not run] |      2s      |      1s
---------------------------------------------------
Total       |  3:47.47  |    5:11.85   |  4:43.77


Using the READ_PLUS operation does have an impact on reading sparse
files over the network.  There is still a big difference between v4.1
and v4.2 runtimes, but this looks to be a result of fallocate() tests
that only run over v4.2.


Changes since v2:
- Encode data segments using splice reads whenever possible.
- Combine patches for adding HOLE and DATA segment support.


These patches and the corresponding client changes are available in the
[read_plus] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (3):
  NFSD: nfsd4_encode_read{v}() should encode eof and maxcount
  NFSD: Add basic READ_PLUS support
  NFSD: Add support for encoding multiple segments

 fs/nfsd/nfs4proc.c |  16 +++++
 fs/nfsd/nfs4xdr.c  | 182 ++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 160 insertions(+), 38 deletions(-)

-- 
2.3.3

