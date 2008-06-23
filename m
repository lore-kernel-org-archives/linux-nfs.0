From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] NFS mounting with raw IPv6 server hostnames (take 3)
Date: Mon, 23 Jun 2008 12:36:28 -0400
Message-ID: <20080623163129.10539.15565.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30820 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbYFWQm5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 12:42:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

These four patches introduce the ability to mount NFS servers using a raw IPv6
address.  This support requires the ability to handle colons in the passed-in
server hostname, and the ability to handle an IPv6 interface identifier in the
passed-in server hostname.  This series adds both features.

IPv6 addresses contain colons.  A colon is also used to separate the server
name from the export path.  By enclosing an IPv6 address inside square
brackets, we effectively escape the colons in the IPv6 address and allow them
to pass unrecognized through the device name parser.

As an added bonus, I have also included the patch that changes
nfs_parse_server_address() to take a name length.  This allows the passed-in
address string to have no '\0'-termination, which will help us support IPv6
addresses in NFSv4 referrals.

I posted this version of the second patch to netdev@ last week, but have heard
no objections.  Please replace earlier versions of these patches with this set.

---

Chuck Lever (4):
      NFS: handle interface identifiers in incoming IPv6 addresses
      NFS: Add string length argument to nfs_parse_server_address
      NFS: Support raw IPv6 address hostnames during NFS mount operation
      NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3


 fs/nfs/super.c       |  337 +++++++++++++++++++++++++++++++++++++++-----------
 include/linux/inet.h |    7 +
 2 files changed, 269 insertions(+), 75 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com
