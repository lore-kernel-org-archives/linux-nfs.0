Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57228 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754039Ab2KHAo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:44:26 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TWGEM-0007b9-0y
	for linux-nfs@vger.kernel.org; Wed, 07 Nov 2012 19:44:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: implement backchannel security negotation
Date: Wed,  7 Nov 2012 19:44:18 -0500
Message-Id: <1352335463-29084-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an incomplete implementation of the (mandatory) NFSv4.1
backchannel security negotation, only enough to handle auth_unix and
auth_null; auth_gss will need more work.

--b.

