From: Orion Poplawski <orion@cora.nwra.com>
Subject: NFS slow to respond on resumption from hibernate
Date: Thu, 10 Sep 2009 16:15:42 +0000 (UTC)
Message-ID: <loom.20090910T180831-552@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49995 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbZIJQQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 12:16:05 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MlmJa-0006JA-Ng
	for linux-nfs@vger.kernel.org; Thu, 10 Sep 2009 18:16:07 +0200
Received: from inferno.cora.nwra.com ([65.44.101.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 18:16:06 +0200
Received: from orion by inferno.cora.nwra.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 18:16:06 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've started hibernating some of our Fedora desktop machines.  Problem is that
we have NFS mounted home (and some other) directories and access to these can be
*slow* (several minutes) to recover on resumption from hibernate.  Other network
activity is fine.  Fedora bug is here:

https://bugzilla.redhat.com/show_bug.cgi?id=510536

Any thoughts on what might be causing this or how to debug?

Thank you,

  Orion


