Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57681 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab0JUQU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:28 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P8xsR-0002Rq-Bf
	for linux-nfs@vger.kernel.org; Thu, 21 Oct 2010 12:20:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: sessions patches
Date: Thu, 21 Oct 2010 12:20:07 -0400
Message-Id: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches fix bugs in and do some minor cleanup of the
server 4.1 sessions code.  I'm thinking of submitting them for 2.6.37.

They come from efforts to prepare some patches that address:

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Trunking
	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#BIND_CONN_TO_SESSION

which aren't yet ready to merge.  (They may still be ready in time for
2.6.37, but I'm not sure.)

--b.
