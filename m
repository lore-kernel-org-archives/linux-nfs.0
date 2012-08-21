Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46787 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361Ab2HUU5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:34 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1T3vW2-0004oW-Dl
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 16:57:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: nfsd & svcrpc patches (mainly cleanup) for 3.7
Date: Tue, 21 Aug 2012 16:57:18 -0400
Message-Id: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This mainly cleanup (and one minor bugfix) noticed while I was debugging
some problems in the neighborhood.

--b.

