From: <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.0 -- nfs client runs 15x faster if client app runs as root.
Date: Thu, 8 Jan 2004 16:23:02 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <33659.68.42.103.198.1073575382.squirrel@webmail.uio.no>
References: <33640.68.42.103.198.1073574746.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <gael.roualland@oleane.net>, <ewhiting@amis.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Aec09-00037u-L3
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:23:13 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aec09-0000Md-6W
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:23:13 -0800
To: <nfs@lists.sourceforge.net>
In-Reply-To: <33640.68.42.103.198.1073574746.squirrel@webmail.uio.no>
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


> Yeah. It turned out to be remove_suid() that was causing an empty
> SETATTR to be sent after every write(). The solution is just to filter
> out all requests that will result in empty SETATTRs. The server will
> automatically do the honours w.r.t. the suid bit as soon as it receives
> our write.

Note: I've already added this fix to the 2.6.1 NFS4_ALL patch
(see http://www.fys.uio.no/~trondmy/src/Linux-2.6.x/2.6.1)

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
