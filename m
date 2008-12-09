From: Adesuyan <bobby-ufAfj23ATiXovzDjfJyo/Q@public.gmane.org>
Subject: NSFproblem lockd: server  not responding, still trying
Date: Wed, 10 Dec 2008 00:36:27 +0100
Message-ID: <493F00FB.2060105@aust.edu.ng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [77.73.186.34] ([77.73.186.34]:55821 "EHLO aust-abuja.org"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752129AbYLJAEd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2008 19:04:33 -0500
Received: from [172.20.4.4]
	by aust-abuja.org with esmtp (Exim 4.69)
	(envelope-from <bobby-ufAfj23ATiXovzDjfJyo/Q@public.gmane.org>)
	id 1LACAJ-0001qi-I0
	for linux-nfs@vger.kernel.org; Wed, 10 Dec 2008 00:38:57 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi guys

am having some issues with nfs the home directories of all the computers 
in my school is mounted on the fileserver via nfs mount . for quite some 
times now users have been experiencing issues with their desktop 
freezing.   i checked the syslogs and i found this 
http://pastebin.com/m69dde24e
    a little googling showed there was a kernel 2.6 bug which happens 
when you  have had with fast server cards and slow client cards when a
                   2.6.x kernel is used on the server.
   the fileserver is on a gigabit card
    while the client are all on 10/100  so i guess am affected
   i tried apply the fix in this wiki 
http://wiki.ltsp.org/twiki/bin/view/Ltsp/NFS#NFS_Server_not_responding
  but am not sure if i got it right .. or if it applies to the case 
where one mounts the home directory from the fileserver but the system
  boots up local (not through the network)
 someone i met at #linux-nfs suggested i use NFS over TCP on the client 
i did but it didnt fix the issue am running ubuntu hardy heron on an HP 
server . any help would be appreciated.this problem has made life very 
frustrating for staffs of my school because we use only linux it would 
be a great relive if you guys can help us resolve it. thanks in advance
