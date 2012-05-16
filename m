Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44914 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932973Ab2EPMsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:42 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1SUdej-0004Wr-LK
	for linux-nfs@vger.kernel.org; Wed, 16 May 2012 08:48:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: exchange_id changes for 3.5
Date: Wed, 16 May 2012 08:48:28 -0400
Message-Id: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up exchange_id and fix a few bugs along the way, noticed while I
was working on something else.

Also fix the longstanding setclientid/setclientid_confirm bug that we
compare only mapped uid's when determining the principal associated with
a client, though those mapped uid's are often the same.

--b.

