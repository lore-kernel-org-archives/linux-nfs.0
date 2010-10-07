Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42063 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab0JGPxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 11:53:09 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P3smI-0007Ov-2Z
	for linux-nfs@vger.kernel.org; Thu, 07 Oct 2010 11:53:06 -0400
Date: Thu, 7 Oct 2010 11:53:06 -0400
To: linux-nfs@vger.kernel.org
Subject: server 4.1 issues list
Message-ID: <20101007155306.GA28053@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Based on conversation at the bakeathon yesterday, I've updated

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

Changes:
	- Mark deferral fixes done.
	- Update in-progress status at
	  http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#4.1
	- Add callback error handling.
	- Various minor clarifications.

Some sort of difficulty or time-required rating was also requested, but
I haven't attempted that.

Someone asked whether we error out as we should on
mandatory-not-to-implement 4.1 operations; from a quick check of the
code it appears that we do, so I haven't added that.

Someone also asked whether we've fixed the backchannel attribute
checking.  We haven't, but that should be fairly quick--I'll take a look
at it now.

--b.
