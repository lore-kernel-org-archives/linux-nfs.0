Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:46213 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab2C0PyF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2012 11:54:05 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id q2RFs3iR029859
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2012 17:54:03 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id q2RFs33Z020138
	for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2012 17:54:03 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia2.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id q2RFs3dV001962
	for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2012 17:54:03 +0200
Message-ID: <4F71E29B.70106@cea.fr>
Date: Tue, 27 Mar 2012 17:54:03 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Client says "Stale NFS file handle" but server does not return NFS3ERR_STALE
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have the following issue:
Client does a classical "mount -o vers=3,lock server:/path /mnt". The 
server is my nfs-ganesha user space server.
Then, a long time running "dd if=/dev/zero of=./foo..." is made inside a 
directory in the mount point. No matter what the other parameters of dd 
(like bs= or count=) are : I kill the daemon, and restart it a couple of 
seconds later. Then I kill the dd (CTRL-C from the console). The dd 
command returns an error (which is logical, it' sis IO error or Bad File 
Descriptor), but I see something else that is quite strange:
    - if I ls from the current directory (where I ran 'dd'), I got the 
message "ls: cannot open directory .: Stale NFS file handle"
    - In wireshark, I see no NFS3ERR_STALE
The wireshark capture shows that the "server shutdown" was made between 
a WRITE reply and the related COMMIT call (I received the COMMIT call as 
the server rebooted).
Apparently, the client decided to return "Stale NFS  file handle" to the 
client, the server returns no error, all replies are NFS3_OK.
What  should I be looking for to fix this bug ? (which is probably on my 
side)

    Regards
   
       Philippe


