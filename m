From: Malte Cornils <malte@cornils.net>
Subject: NFS locking and OpenBSD
Date: Mon, 31 Jan 2005 23:02:30 +0100
Message-ID: <200501312302.30778.malte@cornils.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: admin@usta.de
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvjd3-00085a-16
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 14:02:41 -0800
Received: from smtp1.rz.uni-karlsruhe.de ([129.13.185.217])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cvjd0-0003kt-1f
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 14:02:40 -0800
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

Hello,

since OpenBSD as NFS-server supports only NLM 1,2,3. Linux clients with no 
specific mount options use NFS version 3. However, Linux uses NLM version 4 
with that (fs/lockd/nlmclnt_proc.c, line 113 in 2.6.8).

When set to nfsvers=2, it works, but NFS 2 is (too) slow due to caching etc.

Could we simply set NLM locking version to 1 in the source code 
unconditionally (even for NFS version 3) and expect NFS to work (i.e. is NFS 
protocol 3 able to use older NLM versions than 4)? Of course, I only expect 
an answer from the Linux point of view.

-Malte

BTW, I've tried to search the mailing list archives but only found a post from 
2002 with no answer. 

(BTW, anyone using KDE on NFS-mounted homedirs? The problem occurs in the 
startup phase in kded (when the second icon in the splash blinks) at first 
login. On a local file system, the login is 20-30 seconds faster than on our 
NFS-mounted homedirs)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
