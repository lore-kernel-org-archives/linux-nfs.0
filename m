From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Support parsing multiple security flavors
Date: Tue, 24 Jun 2008 16:33:29 -0400
Message-ID: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:52698 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbYFXUdx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 16:33:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

The following four patches implement support in the NFS client's mount option
parser for multiple security flavors via "sec=flavor:flavor:flavor:..."  This
replicates similar support in the legacy (non text-based) mount.nfs command.

Since the NFS client itself doesn't support multiple security flavors at the
moment, these have been build-tested only.

Please consider them for 2.6.27.

---

Chuck Lever (4):
      NFS: text-based mounts should support multiple security flavors
      NFS4: Set security flavor default for NFSv4 mounts like other defaults
      NFS: Set security flavor default for NFSv2/3 mounts like other defaults
      NFS: Refactor logic for parsing NFS security flavor mount options


 fs/nfs/internal.h |    4 +
 fs/nfs/super.c    |  187 +++++++++++++++++++++++++++++------------------------
 2 files changed, 105 insertions(+), 86 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com
