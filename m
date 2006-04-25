From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: Small UDP frame
Date: Tue, 25 Apr 2006 17:30:42 -0400
Message-ID: <1146000642.5642.1.camel@localhost.localdomain>
References: <Pine.SOC.4.62.0604251811440.23035@diamant>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FYV74-0001yg-HF
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 14:30:26 -0700
Received: from imf16aec.mail.bellsouth.net ([205.152.59.64])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FYV73-0004o4-7F
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 14:30:26 -0700
Received: from ibm56aec.bellsouth.net ([72.148.41.34])
          by imf16aec.mail.bellsouth.net with ESMTP
          id <20060425212948.QDVL11568.imf16aec.mail.bellsouth.net@ibm56aec.bellsouth.net>
          for <nfs@lists.sourceforge.net>; Tue, 25 Apr 2006 17:29:48 -0400
To: christophe.caron@jouy.inra.fr
In-Reply-To: <Pine.SOC.4.62.0604251811440.23035@diamant>
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

On Tue, 2006-04-25 at 18:20 +0200, christophe.caron@jouy.inra.fr wrote:
> Actually i've no more idea about the performance problems. NFS which block 
> IO ? How could i get more information about this network trafic ?

Capture the data in binary format (tcpdump can do this with the -w
option, though you may need to increase the snarflen with -s) and then
have a look at it with a packet analyzer (such as ethereal).

-- Jeff




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
