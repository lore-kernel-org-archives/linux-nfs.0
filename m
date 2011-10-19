Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:40709 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754109Ab1JSPPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 11:15:14 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RGXrK-0004Qy-9b
	for linux-nfs@vger.kernel.org; Wed, 19 Oct 2011 17:15:10 +0200
Received: from ebox.rath.org ([173.255.235.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 17:15:10 +0200
Received: from Nikolaus by ebox.rath.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 17:15:10 +0200
To: linux-nfs@vger.kernel.org
From: Nikolaus Rath <Nikolaus@rath.org>
Subject: Does NFS4 need st_gen?
Date: Wed, 19 Oct 2011 10:17:43 -0400
Message-ID: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Does NFS4 still depend on inode generation numbers? I understand that
earlier NFS versions used file handles based on inode and generation
number, but it seems to me that this shouldn't be required anymore with
the (stateful) NFS4.

Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C

