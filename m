Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.framestore.com ([193.203.83.5]:41802 "EHLO
	mx4.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3ENLu4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 May 2013 07:50:56 -0400
Received: from vm-zimbra.ldn.framestore.com ([172.16.73.68] helo=zimbra.framestore.com)
	by mx4.framestore.com with esmtp (Exim 4.72)
	(envelope-from <james.vanns@framestore.com>)
	id 1UcDHw-0003F2-8r
	for linux-nfs@vger.kernel.org; Tue, 14 May 2013 12:21:06 +0100
Received: from mailbox1.framestore.com (mailbox1.framestore.com [172.16.73.65])
	by zimbra.framestore.com (Postfix) with ESMTP id 2DA871E51057
	for <linux-nfs@vger.kernel.org>; Tue, 14 May 2013 12:20:16 +0100 (BST)
Date: Tue, 14 May 2013 12:17:10 +0100 (BST)
From: James Vanns <james.vanns@framestore.com>
Reply-To: james.vanns@framestore.com
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <433790995.19587230.1368530229981.JavaMail.root@framestore.com>
Subject: Where in the server code is fsinfo rtpref calculated?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. I'm struggling to locate the region in the NFSv3 server-side code where it figures out the block sizes for the FSINFO reply. We have servers that do not specify r/wsizes in their exports and so I need to find where this negotiated 
value between server->client actually comes from. How does the server reach the preferred block size for a given export?

Cheers,

Jim

-- 
Jim Vanns
Senior Software Developer
Framestore

