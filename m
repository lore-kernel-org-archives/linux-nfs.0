From: Mike Frysinger <vapier@gentoo.org>
Subject: libtirpc and nis
Date: Wed, 3 Jun 2009 10:02:36 -0400
Message-ID: <200906031002.38551.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:40572 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbZFCOCh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 10:02:37 -0400
Received: from vapier.localnet (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 41A3A655A8
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2009 14:02:39 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the libtirpc package is self described as a "standalone package".  i wonder 
how far that actually goes.  wrt NIS, it requires the system C library to 
provide NIS functionality or you get a build failure in a few files.  would be 
nice if libtirpc were usable without any NIS baggage at all.
-mike
