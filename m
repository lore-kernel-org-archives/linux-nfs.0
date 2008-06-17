From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] NFS mounting with raw IPv6 server hostnames
Date: Tue, 17 Jun 2008 14:17:09 -0400
Message-ID: <20080617181622.3215.61295.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:64326 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756AbYFQSRh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 14:17:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Something meatier today.

These four patches introduce the ability to mount NFS servers using a raw
IPv6 address.  This support requires the ability to handle colons in the
passed-in server hostname, and the ability to handle an IPv6 interface
identifier in the passed-in server hostname.

IPv6 addresses contain colons.  A colon is also used to separate the server
name from the export path.  By enclosing an IPv6 address inside square
brackets we effectively escape the colons in the IPv6 address and allow them
to pass unrecognized through the device name parser.

As an added bonus, I also include the patch that changes
nfs_parse_server_address() to take a name length.  This allows the passed-in
address string to have no '\0'-termination, which will help us support IPv6
for NFSv4 referrals.

Please consider these for 2.6.27.

---

Chuck Lever (4):
      NFS: handle interface identifiers in incoming IPv6 addresses
      NFS: Add string length argument to nfs_parse_server_address
      NFS: Support raw IPv6 address hostnames during NFS mount operation
      NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3


 fs/nfs/super.c |  336 ++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 261 insertions(+), 75 deletions(-)

-- 
Chuck Lever
chu ckd otl eve rat ora cle dot com
