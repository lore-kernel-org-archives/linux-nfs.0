From: Nicolas Kowalski <Nicolas.Kowalski@imag.fr>
Subject: nfs "storm", additionnal information
Date: Fri, 13 Jun 2003 15:47:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vqor85yks2j.fsf@astazou.imag.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from imag.imag.fr ([129.88.30.1])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Qoto-0008Ge-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 06:47:25 -0700
Received: from mail-veri.imag.fr (pave.imag.fr [129.88.43.12])
	by imag.imag.fr (8.12.9/8.12.9) with ESMTP id h5DDlH9H020161
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 15:47:17 +0200 (CEST)
Received: from astazou.imag.fr
	([129.88.43.102] helo=astazou.imag.fr.imag.fr ident=kowalski)
	by mail-veri.imag.fr with esmtp (Exim 3.35 #1 (Debian))
	id 19Qoth-0005eG-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 15:47:17 +0200
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


Further investigation showed me that the knfsd processes seems to take
an giant CPU percentage only when the user's quotas are exceeded:

- user 'foo' has a quota of 200MB max on /home/foo, and uses ~150MB.

- user "foo" launch an IO-heavy application.

- the application writes large amounts of data on /home/foo

  => knfsd on the server keeps cool


- when the foo's quotas are exceeded, the application does not check
for it, and keeps writing data on /home/foo

  => knfsd on the server goes crazy


Here is what I can see using tcpdump:

15:24:27.914925 client > server: (frag 46149:924@7400)
15:24:27.915111 client > server: (frag 46149:1480@5920+)
15:24:27.915234 client > server: (frag 46149:1480@4440+)
15:24:27.915368 client > server: (frag 46149:1480@2960+)
15:24:27.915480 client > server: (frag 46149:1480@1480+)
15:24:27.915603 client.2734922064 > server.nfs: 1472 write [|nfs]
 (frag 46149:1480@0+)
15:24:27.933821 server.nfs > client.2617481552: reply ok 120 writ
e ERROR: Disc quota exceeded (DF)
15:24:27.934151 client > server: (frag 46150:924@7400)
15:24:27.934328 client > server: (frag 46150:1480@5920+)
15:24:27.934452 client > server: (frag 46150:1480@4440+)
15:24:27.934581 client > server: (frag 46150:1480@2960+)
15:24:27.934704 client > server: (frag 46150:1480@1480+)
15:24:27.934828 client.2751699280 > server.nfs: 1472 write [|nfs]
 (frag 46150:1480@0+)
15:24:27.953074 server.nfs > client.2634258768: reply ok 120 writ
e ERROR: Disc quota exceeded (DF)


The filesystems are XFS (CVS ~15 May), if this does matter.

-- 
Nicolas



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
