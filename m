From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: minor filehandle-related patches for 2.6.32
Date: Fri,  4 Sep 2009 15:47:00 -0400
Message-ID: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50164 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757262AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1MjekU-0001TH-Br
	for linux-nfs@vger.kernel.org; Fri, 04 Sep 2009 15:47:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've collected some minor patches for 2.6.32 addressing leaks found by
Trond, with some cleanup.  (Mainly: I find fh_compose too long to read 
easily.)

--b.
