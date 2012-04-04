Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:39316 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756327Ab2DDODJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Apr 2012 10:03:09 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SFQni-0004Sc-Ru
	for linux-nfs@vger.kernel.org; Wed, 04 Apr 2012 16:03:06 +0200
Received: from bg-1.or.uni-bonn.de ([131.220.141.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 04 Apr 2012 16:03:06 +0200
Received: from bartoschek by bg-1.or.uni-bonn.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 04 Apr 2012 16:03:06 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <bartoschek@gmx.de>
Subject: Re: nfsd hangs for more than 120 seconds
Date: Wed, 04 Apr 2012 15:58:29 +0200
Message-ID: <6l0u49-4r5.ln1@barney.bruehl.pontohonk.de>
References: <p9nj49-5hf.ln1@homer.bruehl.pontohonk.de> <68163.71483.qm@web100706.mail.kks.yahoo.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have just seen that the time on our NIS server was several minutes off. 
Could this be the reason for our problems?

I know that kerberos needs accurate time, but is this also the case for NIS?

Christoph

