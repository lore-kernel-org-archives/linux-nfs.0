From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 2] Introduction
Date: Tue, 27 Jul 2004 14:09:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040727140509.21492.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpJHK-0002rW-O5
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:09:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BpJHK-00018Q-9i
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:09:26 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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

Hi Marcelo,
 I wonder if there is any chance of getting these two nfsd patches into 2.4.27.  Both are very minor.

 The first simply remote the EXPERIMENTAL flag for NFS over TCP.  NFS service over TCP has been working 
quite well for a while now and there is no need to keep it experimental.

 The second changes the MAXBLKSIZE of nfs server to be a function of PAGE_SIZE.
 The currently value of 8K was chosen because it is 
   1/ big enough to be useful
   2/ small enough to not cause kmalloc problems when a buffer that large is needed.

 On machines with larger PAGE_SIZE, it is smaller than needed and a bigger number will be more useful.

Thanks,
NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
