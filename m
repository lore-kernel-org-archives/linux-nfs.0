From: "Vithal Shirodkar" <vithals@hotmail.com>
Subject: nfsd dies quietly in anaconda loader
Date: Tue, 04 Oct 2005 21:45:24 -0700
Message-ID: <BAY101-F1370AF195FDE8C4E12D44BB2820@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EN19k-0001If-Ou
	for nfs@lists.sourceforge.net; Tue, 04 Oct 2005 21:45:28 -0700
Received: from bay101-f13.bay101.hotmail.com ([64.4.56.23] helo=hotmail.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EN19j-0000h2-Mn
	for nfs@lists.sourceforge.net; Tue, 04 Oct 2005 21:45:28 -0700
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

I modified anaconda loader to complete startup till network is up and call 
my script where I try to load nfs server.  I did insmod for nfsd, nfs, 
lockd, sunrpc and see that these modules are up.  However, when I do a 
/etc/rc.d/init.d/nfs start I get a OK message but ps -e reports that nfs is 
not running.

My goal is to have a basic kernel running which will have nfs server up 
without going through init.

vithals




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
