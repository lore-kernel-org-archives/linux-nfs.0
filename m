From: redshield88888 <redshield88888@gmail.com>
Subject: An empty file can create but I can't r/w from a pNFS-client with Fsync error. Why?
Date: Tue, 25 May 2010 08:38:59 +0000 (UTC)
Message-ID: <loom.20100525T103230-488@post.gmane.org>
References: <loom.20100525T040243-971@post.gmane.org> <4BFB4A51.8040405@panasas.com> <loom.20100525T073755-468@post.gmane.org> <4BFB6BD7.1080905@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:51551 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756217Ab0EYIjQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 04:39:16 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OGpfN-0004Uw-Qu
	for linux-nfs@vger.kernel.org; Tue, 25 May 2010 10:39:13 +0200
Received: from softbank221086052216.bbtec.net ([221.86.52.216])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 10:39:13 +0200
Received: from redshield88888 by softbank221086052216.bbtec.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 10:39:13 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've met the "Fsync Error" on the vim when I save the document on a pNFS-client.
I can't read and write file contents! I've only able to generate zero-size file
from a pNFS-client. orz


