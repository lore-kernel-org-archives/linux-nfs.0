Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab3IEPtn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 11:49:43 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1VHboU-0005q7-0F
	for linux-nfs@vger.kernel.org; Thu, 05 Sep 2013 11:49:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: gss-proxy fix for large kmalloc
Date: Thu,  5 Sep 2013 11:49:29 -0400
Message-Id: <1378396173-22352-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We overlooked the size of the gssproxy reply--it's too big to allocate a
single xdr buffer for.  The following patches fix that and do a little
additional cleanup.

