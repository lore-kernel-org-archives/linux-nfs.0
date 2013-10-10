Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59332 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752443Ab3JJPPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 11:15:07 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1VUHxD-00011M-9P
	for linux-nfs@vger.kernel.org; Thu, 10 Oct 2013 11:15:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: miscellaneous gss-proxy & krb5 fixes for 3.13
Date: Thu, 10 Oct 2013 11:14:59 -0400
Message-Id: <1381418103-3852-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are some (what look like mostly minor) fixes prompted by some
static checker results from Andi Kleen.  I'm planning to queue them up
for 3.13.

--b.

