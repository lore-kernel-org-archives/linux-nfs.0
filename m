Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52274 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932221Ab0FOO3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:06 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 2BCF518161
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/10] layout refcounting changes 
Date: Mon, 14 Jun 2010 21:46:05 -0400
Message-Id: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following are more of code style changes, as opposed to functionality
changes.

patches 1-3 change refcounting on the layout

patches 4-10 change the layout to be a pointer to a "cache_head".
Layout drivers are expected to embed the cache_head in their private
structures.

Fred

