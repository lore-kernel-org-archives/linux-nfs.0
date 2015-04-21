Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38934 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932686AbbDUUWS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 16:22:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: patches for 4.1
Date: Tue, 21 Apr 2015 16:22:12 -0400
Message-Id: <1429647735-15512-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These fix a couple bugs I noticed (plus one Christoph caught) while
reviewing some nfsd permissions checking (partly for richacl review).

I'll probably send my 4.1 pull request tomorrow, with these (and the
rest mostly small bugfixes too).

--b.

