From: "Gomez, Daniel" <dgomez@tigr.ORG>
Subject: Re: bug in linux mount? (says NetApp)
Date: Tue, 11 Jul 2006 22:13:44 -0400
Message-ID: <7F0AA25C9B1706448E8B73DFDD109B31028E5B13@EXCHANGE.TIGR.ORG>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0UF9-00085F-Fd
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 19:14:27 -0700
Received: from ranger.tigr.org ([192.207.234.252])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0UF9-00039V-HW
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 19:14:27 -0700
To: <autofs@linux.kernel.org>, <nfs@lists.sourceforge.net>
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

Hello,

>> * What do you think proper options for NFS auto/mounts would be for
>> extremely busy centralized NFS filers?
>
>Something like
>
>mount -t nfs -ohard,timeo=600,retrans=2,rsize=32768,wsize=32768,tcp
foo:/ /bar
>
>should be a fairly safe bet. You might want to add the 'intr' flag too,
depending on how you feel about the behaviour w.r.t. pressing ^C.


We use the following setup with good results and without loss of
functionality (assuminig linux defaults [eg, 'hard','rw', etc]):

For read-only filesystem:
	
ro,rsize=32768,wsize=32768,timeo=600,actimeo=600,intr,tcp,nfsvers=3

For read-write:
	rsize=32768,wsize=32768,timeo=600,actimeo=120,intr,tcp,nfsvers=3

-Daniel


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
