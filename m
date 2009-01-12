From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: [PATCH,RFC] more graceful sunrpc cache updates for HA
Date: Mon, 12 Jan 2009 21:25:02 +1100
Message-ID: <496B1A7E.80807@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050900020403090001070104"
Cc: Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:44909 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751150AbZALKdM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 05:33:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050900020403090001070104
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

G'day,

This is a pair of patches which attempt to make the sunrpc caching
mechanism more graceful with respect to administrative exportfs changes
from userspace while traffic is flowing to other exports.

The patches are not to be applied and are for comment, to allow someone
else to finish this work, and to document the problem. The patches are 
incomplete and not tested.  The patches are against the archaic SLES10
versions of the kernel and nfs-utils and will need some work for modern
software.

Here's a description of the problem.  The current behaviour when an
export is changed (added, removed, or the flags are changed) using
exportfs is that exporfs writes a new etab and then tells the kernel to
flush the entire kernel-side export state (including the state for
exports and clients which are not logically affected by the change) and
refresh everything by triggering upcalls to rpc.mountd.  Most of the
time this works fine, but there's an ugly interaction which can happen
when a client is generating a workload comprising entirely WRITE calls. 
--------------050900020403090001070104--
