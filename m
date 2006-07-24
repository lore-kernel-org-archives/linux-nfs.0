From: Manish RATHI <manish.rathi@st.com>
Subject: Nfs problem on target
Date: Mon, 24 Jul 2006 11:51:26 +0530
Message-ID: <003101c6aee9$64f41a90$802cc70a@dlh.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G4tp7-0002pE-5O
	for nfs@lists.sourceforge.net; Sun, 23 Jul 2006 23:21:49 -0700
Received: from lon-del-02.spheriq.net ([195.46.50.98])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G4tp5-0002NM-UI
	for nfs@lists.sourceforge.net; Sun, 23 Jul 2006 23:21:49 -0700
Received: from lon-out-03.spheriq.net ([195.46.50.131])
	by lon-del-02.spheriq.net with ESMTP id k6O6LeQ9008412
	for <nfs@lists.sourceforge.net>; Mon, 24 Jul 2006 06:21:40 GMT
Received: from lon-cus-02.spheriq.net (lon-cus-02.spheriq.net [195.46.50.38])
	by lon-out-03.spheriq.net with ESMTP id k6O6LdNh009820
	for <nfs@lists.sourceforge.net>; Mon, 24 Jul 2006 06:21:39 GMT
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by lon-cus-02.spheriq.net with ESMTP id k6O6LbNC013493
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=OK)
	for <nfs@lists.sourceforge.net>; Mon, 24 Jul 2006 06:21:39 GMT
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E7FC1DA48
	for <nfs@lists.sourceforge.net>; Mon, 24 Jul 2006 06:21:32 +0000 (GMT)
Received: from mail2.dlh.st.com (mail2.dlh.st.com [10.199.8.22])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 127BA4731D
	for <nfs@lists.sourceforge.net>; Mon, 24 Jul 2006 06:21:30 +0000 (GMT)
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,
When I use NFS on 2.4.20 kernel running on my target board, there is no problem?
When I migrate to 2.6.16 and enabled nfs then 
Whenever I execute an application over nfs which access NFS for
Reading files, I get frequent prints 
"nfs : server 10.199.3.88 not responding, still trying"
" nfs : server 10.199.3.88 OK"

On FAQ it's written this can be because of 
Network congestion 
Overloaded server 
Packets (input or output) dropped by a bad NIC or driver.... 

But this problem is not with 2.4 kernel. 

Thanks
Regards
Manish


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
