From: Bruce Fields <bfields@citi.umich.edu>
Subject: nfs-utils patches for v2/v3 security negotiation
Date: Sun, 10 Aug 2008 22:47:07 -0400
Message-ID: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbYHKCrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Aug 2008 22:47:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is two bits of small cleanup (including the previously sent m_path
field cleanup), followed by a patch that fixes mountd's security
negotiation.  (Till now mountd has just advertised just a static list of
pseudoflavors, which works just well enough most of the time, but we
actually want to use the list of security flavors associated with the
given export.)

--b.
