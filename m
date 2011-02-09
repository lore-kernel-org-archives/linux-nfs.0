Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:55035 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832Ab1BIMpI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 07:45:08 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Pn9Pu-0002eX-3t
	for linux-nfs@vger.kernel.org; Wed, 09 Feb 2011 13:45:06 +0100
Received: from 194.88.55.211 ([194.88.55.211])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 09 Feb 2011 13:45:06 +0100
Received: from karesz999 by 194.88.55.211 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 09 Feb 2011 13:45:06 +0100
To: linux-nfs@vger.kernel.org
From: Karoly Slavic <karesz999@yahoo.com>
Subject: Nfs u32 jiffy counter question
Date: Wed, 9 Feb 2011 12:40:03 +0000 (UTC)
Message-ID: <loom.20110209T133851-968@post.gmane.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi!


I've found a red hat bug forum post regarding this problem, namely that the u32
jiffy counter can overload after ~50 days.
https://bugzilla.redhat.com/show_bug.cgi?id=228801

Has this problem been solved in a kernel release maybe?

Thanks & regards
Karoly Slavic

