From: ramana <ramana@intraperson.com>
Subject: Autodir and nfs
Date: Sun, 14 Nov 2004 09:42:22 +0530
Message-ID: <4196DB26.9040207@intraperson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTBge-0006xU-1Y
	for nfs@lists.sourceforge.net; Sat, 13 Nov 2004 20:08:24 -0800
Received: from smtp.net4india.com ([202.71.128.225])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTBgc-0001wZ-DE
	for nfs@lists.sourceforge.net; Sat, 13 Nov 2004 20:08:23 -0800
Received: from [202.63.116.2] (helo=intraperson.com)
	by smtp.net4india.com with esmtp (Exim 3.36 #1)
	id 1CTBsP-0004B5-00
	for nfs@lists.sourceforge.net; Sun, 14 Nov 2004 09:50:34 +0530
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

Dear nfs team,

I am author of Autodir and for more info please visit 
http://www.intraperson.com/autodir/.

Autodir is performing as expected with user level software like ssh, 
smtp servers etc.

But when NFS is used to mount Autodir maintained directories, NFS 
mounting them perfectly but it is not allowing to enter into those nfs 
mounted directories -- Permission denied.

I did not hack NFS kernel code to give you patch myself. Any solutions?

Thanks in advance.

Regards
ramana

-- 
http://www.intraperson.com




-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
