From: "ALLEN, David" <David.ALLEN@eur.crowncork.com>
Subject: NFS network design
Date: Thu, 17 Feb 2005 11:52:31 -0000
Message-ID: <1DB025F33C6990409DA31A122F9AEBB80157D1B4@zzuk20.crowncork.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1kD0-0001wD-Eg
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 03:52:38 -0800
Received: from relay1.bt.net ([194.72.6.100])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1kCz-0002CX-Vm
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 03:52:38 -0800
Received: from mailhost.eur.crowncork.com ([213.120.71.21] helo=a699uk03.ccsextranet.com)
	by relay1.bt.net with smtp (Exim 3.36 #1)
	id 1D1kCv-0007Hi-00
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 11:52:33 +0000
Received: from a699uk07.crowncork.com ([6.99.137.20])
 by a699uk03.ccsextranet.com (SMSSMTP 4.0.5.66) with SMTP id M2005021711523205644
 for <nfs@lists.sourceforge.net>; Thu, 17 Feb 2005 11:52:32 GMT
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

Hi,

Is there any difference in performance between having a single NFS link
between two machines at a high point in a directory structure, or several
NFS links between the machines lower down the directory structure?

For example,  a directory called users contains two sub directories joe and
fred. Would there be any difference seen in file access on the client if a
single mount was created, users, on the two machines or two mounts created,
/users/joe and /users/fred?

(I know this is a very simple example but just to get the point across)

Thanks in advance for any help.

David


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
