From: MeiJia <cfs_eric@yahoo.com.cn>
Subject: about group membership
Date: Tue, 11 May 2004 11:12:41 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40A10989.80300@yahoo.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BNbkD-0000zg-8H
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:12:45 -0700
Received: from smtp103.mail.sc5.yahoo.com ([66.163.169.222])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BNbkC-0004F0-UR
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:12:44 -0700
To: NFS-devel <nfs@lists.sourceforge.net>
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

Hi developers,

While i'm looking at the NFS (include v4), I didn't find any code which 
handle supplement group membership issues. so I'm curious how could NFS 
deal with following situations, or what's the plan to support:
  - normal supplement groups
  - setuid binaries
  - setgroups binaries

Thanks!

MeiJia



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
