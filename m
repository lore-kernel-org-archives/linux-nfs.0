From: Vince Busam <vbusam@google.com>
Subject: fileid changed messages appearing after upgrade to 2.6.16.1
Date: Tue, 11 Apr 2006 19:45:31 -0700
Message-ID: <443C69CB.4060503@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTVMb-0006KH-6l
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 19:45:49 -0700
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FTVMa-0002Ng-61
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 19:45:49 -0700
Received: from vegeta.corp.google.com (vegeta.corp.google.com [172.24.0.3])
	by smtp-out.google.com with ESMTP id k3C2jbgd010811
	for <nfs@lists.sourceforge.net>; Tue, 11 Apr 2006 19:45:37 -0700
Received: from [10.1.12.12] (smdmzdhcp1-12.corp.google.com [10.1.12.12] (may be forged))
	(authenticated bits=0)
	by vegeta.corp.google.com with ESMTP id k3C2jWZ6013887
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 11 Apr 2006 19:45:36 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

After upgrading from 2.6.13.4 + CITI NFS patch to 2.6.16.1 (with no
patches), I've started seeing error messages like the following:

NFS: server build.nfs error: fileid changed
fsid 0:17: expected fileid 0x5d3644, got 0x5d363c
nfs_update_inode: inode 6108740 mode changed, 0040755 to 0000000

The equivalent errors (the printk output was moved and changed) did not
show up with 2.6.13.4.  Is this a known issue, or is there anything I
can do to help pinpoint the problem?

Thanks,
Vince



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
