From: "John Roberts" <john_roberts@credence.com>
Subject: RE: Linux NFS writes to Solaris very, very slow
Date: Fri, 23 Jul 2004 10:50:32 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407231750.i6NHoWV21459@algebra.hillsboro.credence.com>
Reply-To: John Roberts <john_roberts@credence.com>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Cc: cstuckless@petro-canada.ca, john_roberts@credence.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bo4Bw-0006jC-CR
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 10:50:44 -0700
Received: from hifw1.credence.com ([63.127.103.172] helo=hinscp.hillsboro.credence.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bo4Br-0001S7-8x
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 10:50:44 -0700
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


>I would ensure you are using NFSv3 and TCP (as opposed to UDP) mounts.

I believe I am, but still getting poor Linux client-to-Solaris server
NFS write speed.  Read performance seems okay.


>On our solaris NFS server our automount maps have the following options:
>
>-proto=tcp,vers=3

Ditto here.  For my server volume I have:
vers=3,proto=tcp,sec=sys,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retr
ans=5,timeo=600


>And on the Linux clients I can see this is the case by doing a 'cat
>/proc/mounts':
>
>nfs rw,v3,hard,intr,tcp,lock, 0 0  (edited to remove irrelevant info)

I have similar settings, but not the same.  We also use autofs to
mount the file server for us:

  nfs rw,v3,rsize=32768,wsize=32768,hard,tcp,lock,addr=orfsrv2 0 0



Thanks for the reply!


John Roberts
john_roberts@credence.com




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
