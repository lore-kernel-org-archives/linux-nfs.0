From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: render farm NFS server is having hard time staying up.
Date: Tue, 19 Oct 2004 08:44:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E9B5@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJw9y-0001sC-1i
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 08:44:26 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CJw9w-0002Uf-Jw
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 08:44:25 -0700
To: "Greg Whynott" <greg@dkp.com>
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

> 24 nfsd's fire off at startup.

if you try more than 24, does that help or hurt the situation?

> I have added this as part of the system startup:
> echo 262144 > /proc/sys/net/core/rmem_default
> echo 262144 > /proc/sys/net/core/rmem_max
> /etc/init.d/nfs start
> echo 65536 > /proc/sys/net/core/rmem_default
> echo 65536 > /proc/sys/net/core/rmem_max

i don't understand why you reset these values after you've started nfs.
262144 should be safe to use all the time, and for both rmem and wmem.

you are probably using NFS over UDP.  "netstat -s" on either the client
or server will show you IP fragment reassembly stats that could be one
source of your problem.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
