From: <trond.myklebust@fys.uio.no>
Subject: Re: [NFS client] NFS locks not released on abnormal process termination
Date: Thu, 8 Jan 2004 17:50:56 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35311.68.42.103.198.1073580656.squirrel@webmail.uio.no>
References: <87llpms8yr.fsf@ceramic.fifi.org>
        <1073558844.242410.4086.nullmailer@yamt.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <phil@fifi.org>, <trond.myklebust@fys.uio.no>, <theonetruekenny@yahoo.com>, <linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AedNI-0007nQ-Nv
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 08:51:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AedNI-0004Ki-5P
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 08:51:12 -0800
To: <yamamoto@valinux.co.jp>
In-Reply-To: <1073558844.242410.4086.nullmailer@yamt.dyndns.org>
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

>
> i think it's problematic because you can't assume the lock was
> granted on the server and the signaled process might not exit
> immediately.

The point is that it is *worse* to assume the lock was not granted,
since then it will never get cleared on the server.

The RPC layer blocks all signals except SIGKILL, so the signalled
process has no choice but to exit immediately if something gets
through.

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
