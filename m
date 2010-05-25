From: redshield88888 <redshield88888@gmail.com>
Subject: Can the pNFS be able to construct high-available about the data ?
Date: Tue, 25 May 2010 07:41:59 +0000 (UTC)
Message-ID: <loom.20100525T092804-609@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:50855 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127Ab0EYHmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 03:42:08 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OGom6-0005av-No
	for linux-nfs@vger.kernel.org; Tue, 25 May 2010 09:42:06 +0200
Received: from softbank221086052216.bbtec.net ([221.86.52.216])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 09:42:06 +0200
Received: from redshield88888 by softbank221086052216.bbtec.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 09:42:06 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

I wonder that about the pNFS's high availability.
The pNFS will stripe a file on each DSs, so this file will be currupted when one
DS has crushed, will not ?



