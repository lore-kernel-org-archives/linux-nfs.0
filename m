From: hanasaki <hanasaki@hanaden.com>
Subject: NFS rpc and stale handles on 2.6.x servers
Date: Sun, 25 Jan 2004 19:03:25 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4014675D.2040405@hanaden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AkvAe-0004mq-35
	for nfs@lists.sourceforge.net; Sun, 25 Jan 2004 17:04:08 -0800
Received: from cpe-65-30-34-80.kc.rr.com
	([65.30.34.80] helo=cognition.home.hanaden.com ident=df)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AkvAd-00014b-FC
	for nfs@lists.sourceforge.net; Sun, 25 Jan 2004 17:04:07 -0800
Received: from [192.168.1.30] (helo=hanaden.com ident=hanasaki)
	by cognition.home.hanaden.com with asmtp (Exim 4.30)
	id 1AkvAJ-0000Xt-Bd
	for nfs@lists.sourceforge.net; Sun, 25 Jan 2004 19:03:47 -0600
To: nfs@lists.sourceforge.net
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

The below is being reported, on and off, when hitting nfs-kernel-servers
running on 2.6.0 and 2.6.1  Could someone tell me if this is smoe bug or
what?  Thanks
	RPC request reserved 0 but used 124

Debian sarge
nfs-kernel-server
am-untils
nfsv3 over tcp



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
