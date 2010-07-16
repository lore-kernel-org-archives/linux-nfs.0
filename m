From: Jim Rees <rees@umich.edu>
Subject: nfs-utils atomicio.c
Date: Fri, 16 Jul 2010 15:35:08 -0400
Message-ID: <20100716193508.GA14878@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:40464 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966085Ab0GPTfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 15:35:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by magus.merit.edu (Postfix) with ESMTP id 65CD92254A0
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jul 2010 15:35:08 -0400 (EDT)
Received: from magus.merit.edu ([127.0.0.1])
	by localhost (magus.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Us5bwSGgxrXh for <linux-nfs@vger.kernel.org>;
	Fri, 16 Jul 2010 15:35:08 -0400 (EDT)
Received: from merit.edu (manihiki.merit.edu [198.108.60.79])
	(Authenticated sender: rees-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org)
	by magus.merit.edu (Postfix) with ESMTP id 34CBE22541F
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jul 2010 15:35:08 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Someone should move atomicio.c into nfs-utils/support/nfs.  There are
currently two copies, in idmapd and spnfsd, and I'm about to add a third.
I'll move it if no one has a better idea or beats me to it.
