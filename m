From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Returning error to app on TCP disconnect
Date: Tue, 08 Jun 2010 17:06:46 +0530
Message-ID: <4C0E2B4E.30205@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zp3.zcs.datasyncintra.net ([208.88.241.29]:5021 "EHLO
	zp3.zcs.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab0FHLqy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 07:46:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by zp3.zcs.datasyncintra.net (Postfix) with ESMTP id 6ACFA20E4
	for <linux-nfs@vger.kernel.org>; Tue,  8 Jun 2010 06:36:41 -0500 (CDT)
Received: from zp3.zcs.datasyncintra.net ([127.0.0.1])
	by localhost (zp3.zcs.datasyncintra.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8skM3g7aG18i for <linux-nfs@vger.kernel.org>;
	Tue,  8 Jun 2010 06:36:41 -0500 (CDT)
Received: from [192.168.1.109] (unknown [122.166.12.104])
	(Authenticated sender: shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org)
	by zp3.zcs.datasyncintra.net (Postfix) with ESMTPSA id 6212020E2
	for <linux-nfs@vger.kernel.org>; Tue,  8 Jun 2010 06:36:40 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all

I am working on a setup where when a nfsv3 server goes down, the dd that 
is running on the NFS mount point, gets an error on any syscall 
performed on that mount point, say a write () to a file on that mount.

I've tried setting the timeo and retrans options at mount but that does 
not seem to work in this case. The how-to on linux-nfs site confirms 
that the nfs client just waits for the server to come back up after 
retrans number of requests.

Is there a way to have the app receive an EIO or any other error on TCP 
disconnect?

Thanks
-Shehjar
