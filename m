Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60141 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757593Ab2EAPpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:54 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1SPFGz-0007ve-Dx
	for linux-nfs@vger.kernel.org; Tue, 01 May 2012 11:45:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: 
Date: Tue,  1 May 2012 11:45:43 -0400
Message-Id: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some minor fixes found by sparse, including one and a half actual
(minor) bugs.

--b.

