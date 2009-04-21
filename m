From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: [patches] nfsd-affecting part of vfs queue
Date: Tue, 21 Apr 2009 21:43:41 +0000
Message-ID: <E1LwNkj-0004WL-AW@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60957 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbZDUVnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:42 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1LwNkj-0004WL-AW
	for linux-nfs@vger.kernel.org; Tue, 21 Apr 2009 21:43:41 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fix for out-order dput() vs. mntput() (in nfsd_cross_mnt()) plus
several "switch to passing struct path *" ones.  Comments would
be welcome...

Entire queue is on git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/
in "untested".

