From: andros@netapp.com
Subject: [PATCH 0/2] nfsd41: fix fore channel attribute initialization
Date: Fri, 11 Sep 2009 18:52:53 -0400
Message-ID: <1252709575-3426-1-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19424 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbZIKWxU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 18:53:20 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix forechannel attribute initialization

These two patches fix ca_maxresponsesize_cached, ca_maxresponsesize, and
ca_maxrequestsize calculations for the forechannel.

Tested:

Kerberos NFSv4.1 mount:
Passes Connectathon tests. Passes the expected pynfs tests when tests are run
individually.
When the pynfs tests are run all at once, there are too many sessions created,
and the server code (init_forechannel_attrs) works as planned and fails the
CREATE SESSION with NFS4ERR_SERVERFAULT.

The pynfs 4.1 tests need to be fixed to clean up after themselves! 

-->Andy

0001-nfsd41-fix-NFSD_MIN_HDR_SEQ_SZ.patch
0002-nfsd41-add-RPC-header-size-to-fore-channel-negotiat.patch

