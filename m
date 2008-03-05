From: lizhong <lizhong-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
Subject: Problems in configuring SNFS
Date: Thu, 06 Mar 2008 00:29:19 +0800
Message-ID: <47CECA5F.1000008@ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188]:54122 "HELO ac.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753533AbYCEQih (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 11:38:37 -0500
Received: from [10.10.21.203] (unknown [159.226.41.141])
	by ncic.ac.cn (Postfix) with ESMTP id 6F91B13687C
	for <linux-nfs@vger.kernel.org>; Thu,  6 Mar 2008 00:12:08 +0800 (CST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,
I'm trying to set up SNFS on my Redhat server. I have read all
infomation in this page:
http://www.math.ualberta.ca/imaging/snfs/
I have set up the SNIS server successfully, but when I failed in setting
up the SNFS server. The host name of my SNFS server is gcnode029, and my
client is gcnode010. I can mount directories from gcnode029 to gcnode010
using common NFS, but failed in mount ing directories using SNFS.

I configured SNFS like this:
1. Run command "snfshost gcnode029:200008" at client gcnode010.
2. Add this into /etc/fstab at client gcnode010:
gcnode029:/home/ha /home/ha nfs
user,noauto,hard,intr,rsize=8192,wsize=8192,mountprog=200008,nfsprog=250008
0 0
3. Run command "rpc_psrv -r -d /usr/local/etc/snfs/gcnode029" at client
gcnode010, then enter gcnode029's root password. Now I saw "ID String
correctly read: RPC Proxy Client".
4. Run command "mount /home/ha", then I got the following error message:
mount: mount to NFS server 'gcnode029' failed: RPC Error: Program not
registered.
5. Run command "ps -aux | grep rpc" at host gcnode029:
root 5278 0.0 0.0 1656 744 ? Ss Mar05 0:00 rpc_pcl -P -1 -e
snfs-genode010-200008.log -d -M 200008:100005

If I simply run command "mount -t nfs gcnode029:/home/ha /home/ha", I
could get the remote directory. But in this way, I just used the common
nfs, not SNFS. It seems that for some reason, rpc_psrv received no
message from mount /home/ha, and nothing was sent to host gcnode029.

Thank you for any help!
