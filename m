Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:52980 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241Ab1IENDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 09:03:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id 2C29ECC11E
	for <linux-nfs@vger.kernel.org>; Mon,  5 Sep 2011 15:03:30 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.71])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id UVqIUQQ6m6bN for <linux-nfs@vger.kernel.org>;
	Mon,  5 Sep 2011 15:03:29 +0200 (CEST)
Received: from pc-rsmits.dto.tudelft.nl (pc-rsmits.dto.tudelft.nl [131.180.97.81])
	by mx4.tudelft.nl (Postfix) with ESMTP id A1C56CC105
	for <linux-nfs@vger.kernel.org>; Mon,  5 Sep 2011 15:03:28 +0200 (CEST)
Message-ID: <4E64C8A0.6020806@tudelft.nl>
Date: Mon, 05 Sep 2011 15:03:28 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: linux-nfs@vger.kernel.org
Subject: rpc.mountd switch not working
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I have a question about the use of the following switch with rpc.mountd.

-g  or  --manage-gids

It has come to my attention that the use of this switch is not working 
well in Redhat v6. When I have a user who has a large group membership, 
the following errors appear, and the "cd" command hangs.

Sep  5 14:50:04 srv043 rpc.mountd[2563]: qword_eol: fflush failed: errno 
22 (Invalid argument)

Process :

root      2563     1  0 14:44 ?        00:00:00 rpc.mountd -g

The use of 60 groups is working well, but we have some users with more 
than 100 groups, and those fails. For uid mapping we use Winbind.

/etc/exports :

/export  server.company.com(rw,no_subtree_check,no_root_squash)

Client fstab :

server.company.com:/export   /data           nfs 
nolock,defaults,user        1 2

Can anyone tell me what this error means ?

Greetings .. Richard Smits
