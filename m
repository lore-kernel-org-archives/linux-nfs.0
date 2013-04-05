Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51610 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161475Ab3DEOIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 10:08:09 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UO7JI-0000bM-DN
	for linux-nfs@vger.kernel.org; Fri, 05 Apr 2013 10:08:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: minor delegation cleanup & fixes
Date: Fri,  5 Apr 2013 10:08:02 -0400
Message-Id: <1365170886-2267-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is cleanup of a little bit of delegation recall code, with a fix
for a small race.  For 3.10.

--b.

