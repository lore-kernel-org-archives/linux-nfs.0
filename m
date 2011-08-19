Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:51920 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab1HSAhb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2011 20:37:31 -0400
Received: from smtpdoor@localhost by talus.maths.usyd.edu.au (8.14.3/8.5)
	id p7J0W4er030067 for linux-nfs@vger.kernel.org; Fri, 19 Aug 2011 10:32:04 +1000
Received: from bari.maths.usyd.edu.au (psz@bari.maths.usyd.edu.au) [129.78.69.145]
	by siv.maths.usyd.edu.au via smtpdoor V27.1
	id 30064 for linux-nfs@vger.kernel.org; Fri, 19 Aug 2011 10:32:04 +1000
Date: Fri, 19 Aug 2011 10:32:03 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
Received: from psz@localhost by bari.maths.usyd.edu.au (8.14.3/8.5/Submit)
	id p7J0W3ZX030679 for linux-nfs@vger.kernel.org; Fri, 19 Aug 2011 10:32:03 +1000
To: linux-nfs@vger.kernel.org
Subject: Please support NSF squashing multiple groups
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Linux-NFS people,

NFS has always had the root_squash option, to protect against a remote
and possibly evil root. NFS should also protect all privileged, or at
least all root-equivalent, UIDs and GIDs. Many UNIX distributions have
root-equivalent GIDs, groups whose members could easily become root,
some listed in http://bugs.debian.org/299007#219 .

Currently, NFS has no ways to protect privileged UIDs and GIDs other
than root himself. Such options should be implemented, to make NFS
safer and more useful. As I understand it, the hold-up is not within
NFS code, but with kernel interfaces not supporting lists of squashed
entities. I am asking you to devise and implement such interfaces.

References:
http://bugs.debian.org/299007
http://bugs.debian.org/384922
http://bugs.debian.org/538392
https://bugzilla.kernel.org/show_bug.cgi?id=14295

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
