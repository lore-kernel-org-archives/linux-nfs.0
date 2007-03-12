From: Ming Zhang <blackmagic02881@gmail.com>
Subject: about quota implementation
Date: Mon, 12 Mar 2007 12:11:49 -0400
Message-ID: <1173715909.3889.23.camel@dhcp-107.ibrix.com>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQn7r-0001pj-4b
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:11:55 -0700
Received: from ug-out-1314.google.com ([66.249.92.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQn7q-0004CA-2I
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:11:57 -0700
Received: by ug-out-1314.google.com with SMTP id z38so2409303ugc
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 09:11:52 -0700 (PDT)
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

Hi All

I have a question about current quota implementation. 

This is current implementation. There is a rquotad running on same box
as nfsd. Then in quota-tools, it check if file system type is nfs, then
it invoke a rpc call and get that from rquotad.

Another way is to implement the s_qcops in kernel nfs client and thus
quota-tools can use a unified way to get quotactl information.

Any special reason why not use 2nd way to make quota-tools simpler? One
reason I can think of is to put unnecessary code out of kernel. Is there
any other reason?

Thanks!

Ming
 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
