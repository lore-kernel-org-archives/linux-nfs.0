From: "William Knop" <w_knop@hotmail.com>
Subject: status?
Date: Mon, 18 Nov 2002 10:22:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F172SxvjPkQTGpaoG1V00000b14@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f172.law9.hotmail.com ([64.4.9.172] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Dnjh-0005be-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 07:22:53 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I'm setting up a distributed/clustering filesystem for a research group and 
would like some info/advise.

NFSv4 looks pretty sweet, but is it ready for beta deployment? We'll need to 
have everything up and stable fairly soon, but so far it seems like NFSv4 is 
the only open source FS out there that will satisfy our requirements, of 
which the main ones are partial-file caching and support for large (100GB+) 
filesystems.

Intermezzo forces whole file caching, which will not do. OpenGFS I believe 
is still in alpha stage. OpenAFS only allows for very small filesystems. 
EVMS looks promising, but the clustering FS part is still alpha. I think 
NFSv3 has poor performance, although it would be excellent if it would work.

I'd greatly appreciate any info on distributed/clustering filesystems, 
especially NFSv4 or stable alternatives.

Thanks much,
William Knop

_________________________________________________________________
Help STOP SPAM with the new MSN 8 and get 2 months FREE*  
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
