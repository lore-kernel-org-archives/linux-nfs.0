From: Vince Busam <vbusam@google.com>
Subject: segfault in mount with CITI patch
Date: Wed, 21 Dec 2005 17:30:18 -0800
Message-ID: <43AA01AA.3060705@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpFHt-00015F-IE
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 17:30:33 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EpFHr-0005tG-Dc
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 17:30:33 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com [172.29.48.30])
	by smtp-out.google.com with ESMTP id jBM1UNPM018783
	for <nfs@lists.sourceforge.net>; Wed, 21 Dec 2005 17:30:24 -0800
Received: from [172.29.52.29] (block.smo.corp.google.com [172.29.52.29])
	by mail2.smo.corp.google.com with ESMTP id jBM1UIZJ014567
	for <nfs@lists.sourceforge.net>; Wed, 21 Dec 2005 17:30:18 -0800
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

I've found that mount (from util-linux 2.12 + CITI_NFS4_ALL-3 patch) will segfault with 
this (probably rare) command:

mount -o tcp,nosuid,rw,rsize=8192,wsize=8192,nfsvers=3,mountvers=2,intr,sec=krb5 
server:/volume /mntpoint

This is because nfs_call_mount() will run nfs2_mount() when mountvers=2, but since 
nfsvers=3, nfsmount() will expect certain fields to be filled out, which are not.  Causing 
a segfault here, where flavor points to an invalid address.
1061                            if (flavor[i] == data.pseudoflavor)


Is nfsvers=3,mountvers=2 even OK to do?  If not, mount should print an error instead of 
segfault.

Thanks,
Vince


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
