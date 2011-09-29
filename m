Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:60241 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab1I2OOa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2011 10:14:30 -0400
From: "Tim" <supertimothy@web.de>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
References: <001101cc745e$356aeed0$a040cc70$@web.de> <20110920135050.GA12422@fieldses.org> <001e01cc784b$bba7fa10$32f7ee30$@web.de> <20110921154521.GC21510@fieldses.org>
In-Reply-To: <20110921154521.GC21510@fieldses.org>
Subject: AW: Writing / Locking problem with NFSv4
Date: Thu, 29 Sep 2011 16:13:17 +0200
Message-ID: <003801cc7eb1$ef48f970$cddaec50$@web.de>
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>On Wed, Sep 21, 2011 at 12:46:34PM +0200, Tim wrote:
>> On Fri, Sep 16, 2011 at 12:48:45PM +0200, Tim wrote:
>> >> I’m  facing a rather strange problem. 
>> >> 
>> >> From one client I can mount and access my NFSServer without any problems.
>> >> Writing and locking works with a non root user accout. 
>> >> From another client (in another subnet), with root everything works 
>> >> fine. If I use another user, locking doesnt work and also when I 
>> >> create a file with vim, the *.swp file is not deleted afterwards. 
>> >> But reading works without problems.
>> >> Strange thing is user mapping seems to work correct – at least what 
>> >> ls -la and the logfiles for idmapd shows.
>> 
>> >Which client and server?  (Linux on both?  Which versions?)  Are you using kerberos?  If not, are your uid's the same between client and server?  What does your export file look like?
> 
>> Client and Server are both RHEL 6.1. I am not using kerberos. And yes, the uid's are the same, also the gid is the same: 3000 for both.
>> This is my export file:
> 
>> /srv/nfs/			10.1.4.32/255.255.255.224(rw,fsid=0,sync,no_subtree_check,no_root_squash) 10.1.0.9(rw,fsid=0,sync,no_subtree_check,no_root_squash)
>> /srv/nfs/mail/users		10.1.4.32/255.255.255.224(rw,fsid=1,sync,no_subtree_check,no_root_squash)
>> /srv/nfs/mail/tmp		10.1.4.32/255.255.255.224(rw,fsid=2,sync,no_subtree_check,no_root_squash)
>> /srv/nfs/testdata		10.1.0.9(rw,fsid=10,sync,no_subtree_check,no_root_squash)
>> 
>> I tried to take tcpdumps as root and non root user: They look the same to me. However, I'm not so sure what I'm looking for...

>Hm.  Sounds possibly like

>	http://marc.info/?t=129183437900003&r=1&w=2

I just found out the reason for this whole strange behaviour: The folder, where the device is mounted, must have the right owner and / or rights. That means, if I mount it to /srv/data on client side, the folder data must belong to the user 3000.
I just checked: vim *.swp - files are deleted afterwards and even locking is working!

But thank you anyway, Bruce!
Tim

