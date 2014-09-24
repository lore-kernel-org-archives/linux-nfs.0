Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4.blacknight.com ([78.153.203.207]:56036 "EHLO
	relay4.blacknight.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbaIXPqT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 11:46:19 -0400
Received: from [10.0.2.163] (unknown [91.123.228.33])
	by relay4.blacknight.com (Postfix) with ESMTP id 9CAAC3988C4
	for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 16:39:55 +0100 (IST)
Message-ID: <5422E5CB.6000402@mpstor.com>
Date: Wed, 24 Sep 2014 16:39:55 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS auto-reconnect tuning.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

I've got a scenario where I'm connected to a NFS share on a client, have 
a file descriptor open as read only (could also be write) on a file from 
that share, and I'm suddenly changing the IP address of that client.

Obviously, the NFS share will hang, so if I now try to read the file 
descriptor I've got open (here in Python), the "read" call will also hang.

However, the driver seems to attempt to do something (maybe 
save/determine whether the existing connection can be saved) and then, 
after about 20 minutes the driver transparently reconnects to the NFS 
share (which is what I wanted anyways) and the "read" call instantiated 
earlier simply finishes (I don't even have to re-open the file again or 
even call "read" again).

The dmesg prints I get are as follow:

[ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <-- 
changed IP address and started reading the file.
[ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was 
reconnected, the "read" call completes successfully.

I would like to know if there was any way to tune this behaviour, 
telling the NFS driver to reconnect if a share is unavailable after say 
10 seconds.

I tried the following options without any success:

retry=0; hard/soft; timeo=3; retrans=1; bg/fg

I am running on a custom distro (homemade embedded distro, not based on 
anything in particular) running stock kernel 3.10.18 compiled for i686.

Would anyone know what I could do to force NFS into reconnecting a 
seemingly "dead" session sooner?

Thanks in advance for your help.

Regards,

Ben - MPSTOR.
