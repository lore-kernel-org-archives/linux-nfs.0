From: Christian Nygaard <chris@math.uu.se>
Subject: NFS performance diagnostics
Date: Fri, 10 May 2002 15:53:40 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0205101546400.7377-100000@anarchy.math.uu.se>
References: <E175tAR-0003r9-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elanus.its.uu.se ([130.238.4.143])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 176AqB-0004RS-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 06:53:47 -0700
Received: from elanus (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id C7EB8484D
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 15:51:12 +0200 (DFT)
Received: from geopard.math.uu.se (geopard.math.uu.se [130.238.149.4])
	by elanus.its.uu.se (Postfix) with SMTP id 993344847
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 15:51:09 +0200 (DFT)
To: nfs@lists.sourceforge.net
In-Reply-To: <E175tAR-0003r9-00@usw-sf-list2.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Howdi folks

Can anyone recommend a method of getting information on what files
the nfs daemons is serving? tcpdump shows what files is served
on the network but I get no good stats what each client is using. 

Chris


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
