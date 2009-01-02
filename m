Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60758 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbZABAgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jan 2009 19:36:54 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Cc: Marc Eshel <eshel@almaden.ibm.com>
Subject: NFSv4 LOCKT bypassing ->lock method
Date: Thu,  1 Jan 2009 19:36:49 -0500
Message-Id: <1230856611-32574-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Marc Eshel points out that an NFSv4 LOCKT call is handled without
calling any ->lock() method on the underlying filesystem.

The problem is that NFSv4's LOCKT is really a inode method--it takes a
filehandle, not a stateid, as an argument.  The current code hacks
around this by using a one-off struct file with only the dentry field
initialized.

So the simple fix is to initialize the file operations as well.  But the
original hack makes me a little nervous, so I'm inclined to just do a
temporary open instead.  Objections?

--b.


