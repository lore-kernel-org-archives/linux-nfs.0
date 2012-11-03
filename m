Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:47146 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947Ab2KCIY5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 3 Nov 2012 04:24:57 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1TUZ2O-00025P-2I
	for linux-nfs@vger.kernel.org; Sat, 03 Nov 2012 09:25:04 +0100
Received: from 72.52.96.29 ([72.52.96.29])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 03 Nov 2012 09:25:04 +0100
Received: from xiaojuntime by 72.52.96.29 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 03 Nov 2012 09:25:04 +0100
To: linux-nfs@vger.kernel.org
From: Jun Xiao <xiaojuntime@gmail.com>
Subject: Re: pNFS Block layout issues / questions
Date: Sat, 3 Nov 2012 07:28:17 +0000 (UTC)
Message-ID: <loom.20121103T072206-631@post.gmane.org>
References: <loom.20110328T230906-552@post.gmane.org> <4D977456.1040303@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Seems the thread didn't get any reply for quite a long time.

I'm trying to set up pNFS block layout MDS/DS server, and some 
similar questions as Phil.

- For block layout, is it necessary to make DS export nfs share?
- How could add a block layout DS into pNFS server?
- Does spnfs also work for block layout/

Thanks,
Jun

