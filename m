From: <trond.myklebust@fys.uio.no>
Subject: Re: NFS client write performance issue ... thoughts?
Date: Thu, 8 Jan 2004 18:48:34 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35327.68.42.103.198.1073584114.squirrel@webmail.uio.no>
References: <35321.68.42.103.198.1073583166.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeeGx-0002Vl-6L
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 09:48:43 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AeeGw-0007V9-LZ
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 09:48:42 -0800
To: <pausmith@nortelnetworks.com>
In-Reply-To: <35321.68.42.103.198.1073583166.squirrel@webmail.uio.no>
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

>   2) Linux immediately puts the write on the wire once there are more
> than wsize bytes to write out. This explains why bumping wsize results
> in fewer writes.

Clarification.

The actual condition is really "put all outstanding writes on the wire as
soon as you have wsize/PAGE_SIZE requests, and the last page to be
updated was completely filled".

This flushes out writes on pages that are not currently being accessed
in the background.

Cheers,
  Trond




-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
