From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Errors during a simple mount storm test
Date: Fri, 05 Feb 2010 01:45:33 +0530
Message-ID: <4B6B2AE5.1070007@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zp3.zcs.datasyncintra.net ([208.88.241.29]:34844 "EHLO
	zp3.zcs.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757481Ab0BDUZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 15:25:01 -0500
Received: from localhost (localhost [127.0.0.1])
	by zp3.zcs.datasyncintra.net (Postfix) with ESMTP id C979B20B6
	for <linux-nfs@vger.kernel.org>; Thu,  4 Feb 2010 14:15:31 -0600 (CST)
Received: from zp3.zcs.datasyncintra.net ([127.0.0.1])
	by localhost (zp3.zcs.datasyncintra.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vLR05jH4-sAF for <linux-nfs@vger.kernel.org>;
	Thu,  4 Feb 2010 14:15:31 -0600 (CST)
Received: from [192.168.1.137] (unknown [122.181.11.106])
	(Authenticated sender: shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org)
	by zp3.zcs.datasyncintra.net (Postfix) with ESMTP id D9B4E203B
	for <linux-nfs@vger.kernel.org>; Thu,  4 Feb 2010 14:15:30 -0600 (CST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

The shell command below is probably not applicable to
all real world setups but I wanted to check it out nonetheless.
The problem is with the following command that is supposed
run a mount-umount loop:

$ while [ true ]; do echo sending; mount localhost:/test -o 
noacl,nolock,tcp,mountproto=tcp /mnt;umount  /mnt; done

For the first hundred iterations, it works fine but then starts
spewing errors with the mount command failing. For eg.
the output looks like below:

sending
sending
sending
sending
sending
sending
sending
sending
sending
sending
sending
sending
mount.nfs: mount system call failed
umount: /mnt: not mounted
sending
mount.nfs: mount system call failed
umount: /mnt: not mounted
sending
mount.nfs: mount system call failed
umount: /mnt: not mounted
sending
mount.nfs: mount system call failed
umount: /mnt: not mounted

Any ideas why the mount sequence stops abruptly?
There dont seem to be any relevant messages in the
dmesg output either.

The client and server are on the same machine:
Linux indus 2.6.31-17-generic Ubuntu SMP x86_64 GNU/Linux

I have verified through wireshark that the server is not
receiving any mount requests once the mount command start
failing. Instead there are only successful GETPORT requests
for the MOUNTv3 program.

Thanks
-Shehjar



