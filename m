Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:57768 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759779Ab2FHJmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 05:42:54 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1ScviP-0001Uc-S8
	for linux-nfs@vger.kernel.org; Fri, 08 Jun 2012 11:42:46 +0200
Received: from mail.kuusalu.edu.ee ([195.250.175.154])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jun 2012 11:42:45 +0200
Received: from mikeyuhn by mail.kuusalu.edu.ee with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jun 2012 11:42:45 +0200
To: linux-nfs@vger.kernel.org
From: anon <mikeyuhn@gmail.com>
Subject: Re: rpc.statd is not running but is required
Date: Fri, 8 Jun 2012 09:42:34 +0000 (UTC)
Message-ID: <loom.20120608T114221-767@post.gmane.org>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com> <20110502183547.7e9f1295@notabene.brown> <4DBE80CE.8070406@conversis.de> <830501.99174.qm@web111711.mail.gq1.yahoo.com> <20110502204200.41f71733@notabene.brown> <943072.59877.qm@web111704.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FIX: rpc.statd is not running but is required for remote locking.

For future reference, you need to have rpcbind daemon running on LOCAL MACHINE
where you want to mount the nfs share as well.

