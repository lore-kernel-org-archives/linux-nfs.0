Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:54596 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab1GNJaY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 05:30:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id 65A75108C036
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 11:30:23 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.74])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id BXqv0Du8WIz6 for <linux-nfs@vger.kernel.org>;
	Thu, 14 Jul 2011 11:30:22 +0200 (CEST)
Received: from pc-rsmits.dto.tudelft.nl (pc-rsmits.dto.tudelft.nl [131.180.97.81])
	by mx3.tudelft.nl (Postfix) with ESMTP id D1D2B108C02E
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 11:30:22 +0200 (CEST)
Message-ID: <4E1EB72E.5080803@tudelft.nl>
Date: Thu, 14 Jul 2011 11:30:22 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: linux-nfs@vger.kernel.org
Subject: krb5 mount with large group membership
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list,

I am running into a problem. Perhaps someone understands what is 
happening here. I will explain.

I have a Redhat 5.4 client that is accessing a nfs export on a NFS 
server. (Redhat 6.1)

Our KDC is a Windows AD.

The client is using samba-winbind. If a user is a member of 23 groups or 
lower, I can access the export. If a user is a member of more groups, 
the mount fails with a "Permission denied"

mount /data
-bash-3.2$ cd /data
-bash: cd: /data: Permission denied

Thew odd thing is if I try a mount to our Netapp filer with also a krb5 
export, there is no problem.

This has to do something with the ticket size in combination with 
memberships to a large number of groups.

So what must i do to get this Redhat server working with this setup ? It 
seems that Netapp did something to get this working ?

Does this sound familiar to anyone, or should i provide more information ?

Versions server side :
nfs-utils-1.2.3-7
krb5-workstation-1.9-9

Greetings ... Richard Smits
