Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:49064 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753599Ab1FTHpf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 03:45:35 -0400
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.messagingengine.com (Postfix) with ESMTP id 5E5DD217BE
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2011 03:45:34 -0400 (EDT)
Received: from [10.49.97.31] (124-169-223-87.dyn.iinet.net.au [124.169.223.87])
	by mail.messagingengine.com (Postfix) with ESMTPSA id 4DD7A403217
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2011 03:45:33 -0400 (EDT)
Subject: Umount and delegation release thread syncronization
From: Ian Kent <raven@themaw.net>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jun 2011 15:45:29 +0800
Message-ID: <1308555929.3306.43.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm having difficulty working out how delegation release threads are
synchronized with umount.

For an information about the problem please see
https://bugzilla.kernel.org/show_bug.cgi?id=30882 and in particular
comment #28.

Can someone please give me a description of the sequence of events at
umount (aka. nfs4_kill_super() function calls). In particular how does
nfs_free_server() know that if nfs_super_return_all_delegations() starts
a thread that it is finished before freeing the server struct.

Any information or observations about the opps in the above bug would
also be appreciated.

Ian


