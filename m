Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59379 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277Ab0LQTBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 14:01:53 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1PTfYu-0003lV-VH
	for linux-nfs@vger.kernel.org; Fri, 17 Dec 2010 14:01:53 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: 4.1 secinfo patches
Date: Fri, 17 Dec 2010 14:01:48 -0500
Message-Id: <1292612511-14203-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches implement secinfo_no_name and update secinfo to
meet a 4.1 requirement.

I'll apply them for 2.6.38 if nobody sees a problem.

They look simple enough.  But I don't have a test for them.  So they're
probably wrong.  Two pynfs41 tests would do it:

	- send PUTROOTFH+SECINFO_NO_NAME, check that you get back a
	  legal result.
	- send PUTROOTFH+SECINFO+GETFH, and/or
	  PUTROOTFH+SECINFO_NO_NAME+GETFH, check that the GETFH returns
	  NOFILEHANDLE.

I'll get around to it some day if nobody volunteers.

There are plenty of little things like this that could use doing or
testing before server-side 4.1 is correct; see:

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

--b.
