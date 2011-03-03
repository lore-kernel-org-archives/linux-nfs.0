Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:55873 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180Ab1CCA7P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 19:59:15 -0500
From: Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Give svcgssd access to kernel's supported enctypes
Date: Wed,  2 Mar 2011 19:51:40 -0500
Message-Id: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Make the kernel's supported enctypes available to user-land
(svcgssd) via a new proc file.  The client side already gets
this information in the upcall to gssd, we need to make it
available to svcgssd.

