From: Martin Wilck <martin.wilck@fujitsu-siemens.com>
Subject: nfsroot & RPC_AUTH_NULL
Date: Mon, 12 Jan 2004 13:24:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40029202.3010605@fujitsu-siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Ag17Y-0004uR-0W
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 04:24:40 -0800
Received: from plam.fujitsu-siemens.com ([217.115.66.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ag17X-0004rt-B3
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 04:24:39 -0800
Received: from trolli.pdb.fsc.net ([172.25.96.53])
	by plam.fujitsu-siemens.com (8.11.3/8.11.3) with ESMTP id i0CCOZE11090
	for <nfs@lists.sourceforge.net>; Mon, 12 Jan 2004 13:24:35 +0100
Received: from biker.psw.pdb.fsc.net (biker.pdb.fsc.net [172.25.253.106])
	by trolli.pdb.fsc.net (8.11.6/8.11.6) with ESMTP id i0CCOZA26940
	for <nfs@lists.sourceforge.net>; Mon, 12 Jan 2004 13:24:35 +0100
Received: from fujitsu-siemens.com (localhost.localdomain [127.0.0.1])
	by biker.psw.pdb.fsc.net (8.11.6/8.11.6) with ESMTP id i0CCOYo31618
	for <nfs@lists.sourceforge.net>; Mon, 12 Jan 2004 13:24:34 +0100
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

Hello,

we are experiencing the authentication problems with NFS root under 
Linux which were discussed on this list earlier
(http://marc.theaimsgroup.com/?t=105369226100008&r=1&w=2).

The patch suggested by Trond in
http://marc.theaimsgroup.com/?l=linux-nfs&m=105390025122641&w=2
looks pretty straightforward. Moreover, it appears that trying to mount 
the filesystem with RPC_AUTH_NULL actually violates the NFSv3 spec
(http://www.cis.ohio-state.edu/cgi-bin/rfc/rfc1813.html#sec-5.0).

Can the above mentioned patch have any adverse effects?
If no, is there any reason why it did not become part of either the 
mainline kernel or the patch collection at 
http://www.fys.uio.no/%7Etrondmy/src/ ?

Thanks in advance,
Martin

-- 
Martin Wilck                Phone: +49 5251 8 15113
Fujitsu Siemens Computers   Fax:   +49 5251 8 20409
Heinz-Nixdorf-Ring 1	    mailto:Martin.Wilck@Fujitsu-Siemens.com
D-33106 Paderborn           http://www.fujitsu-siemens.com/primergy







-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
