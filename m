From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] nfs-utils patches
Date: Thu, 11 Dec 2008 13:33:37 -0500
Message-ID: <20081211182820.6882.20716.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:45175 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbYLKSeT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 13:34:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Three more patches for nfs-utils in the IPv6 series.

The first is a minor bug fix for the sm-notify command, since we've
been focusing on that area recently.  It fixes a use-after-free.

The next two don't add new IPv6 functionality, but are prerequisites.
The first adds a new string parsing API that specifically handles
mount options that take a numeric value.  The second changes the
handler for one such option (retry= in this case) to use the new API.

Subsequent patches will make use of this new API to handle mount
options that are used to fill in pmap structs.

---

Chuck Lever (3):
      text-based mount command: use po_get_numeric() for handling retry=
      text-based mount command: add function to parse numeric mount options
      sm-notify command: fix a use-after-free bug


 utils/mount/parse_opt.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/parse_opt.h |    3 +++
 utils/mount/stropts.c   |   20 +++++++++--------
 utils/statd/sm-notify.c |   25 ++++++++++++---------
 4 files changed, 83 insertions(+), 20 deletions(-)

-- 
Chuck Lever
