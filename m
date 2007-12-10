From: Jeff Garzik <jeff@garzik.org>
Subject: pynfs and server attributes?
Date: Mon, 10 Dec 2007 16:30:33 -0500
Message-ID: <475DAFF9.3090206@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Fredric Isaman <iisaman@citi.umich.edu>
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44509 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755334AbXLJVaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 16:30:35 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there a pynfs list somewhere?

The pynfs tests for too-long strings, too-long reads and writes do not 
seem to take into account maxname, maxread and maxwrite attributes.

I actually have to _increase_ the python "longname" test variable in 
order for the test to behave properly on my server :)

	Jeff



P.S.  Thanks to all who contributed to pynfs, it's been a great help.

