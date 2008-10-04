From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: NFS faq
Date: Sat, 4 Oct 2008 16:57:35 -0400
Message-ID: <20081004205735.GC2777@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: csmithere@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56956 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409AbYJDU5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Oct 2008 16:57:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do you still maintain the FAQ at nfs.sourceforge.net?

In A7:

	"There are some minor interoperability issues when applications
	running on clients make use of some of the new features of NFS
	Version 4 such as mandatory locking, share reservations, and
	delegations."

I'd remove "delegations"--they change the performance (most dramatically
if the server has to wait for a lease to time out to allow an open), but
should otherwise be transparent to applications.

The

	NFS-related kernel patches supported by Trond Myklebust
	NFS-related kernel patches supported by Neil Brown 

links should probably just be removed and replaced by a "linux
development" link to linux-nfs.org.

--b.
