From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: Re: Re: [NFS client] NFS locks not released on abnormal process
 termination
Date: Fri, 09 Jan 2004 11:56:26 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1073616986.525187.4709.nullmailer@yamt.dyndns.org>
References: <35311.68.42.103.198.1073580656.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: phil@fifi.org, theonetruekenny@yahoo.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AempC-0005eI-3X
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 18:56:38 -0800
Received: from fla1aak172.kng.mesh.ad.jp ([218.42.70.172] helo=yamt.dyndns.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AempB-0000Sq-PJ
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 18:56:37 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: Your message of "Thu, 8 Jan 2004 17:50:56 +0100 (CET)"
	<35311.68.42.103.198.1073580656.squirrel@webmail.uio.no>
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

hi,

> > i think it's problematic because you can't assume the lock was
> > granted on the server and the signaled process might not exit
> > immediately.
> 
> The point is that it is *worse* to assume the lock was not granted,
> since then it will never get cleared on the server.

yes.

> The RPC layer blocks all signals except SIGKILL, so the signalled
> process has no choice but to exit immediately if something gets
> through.

we're talking about interruptible mounts, aren't we?

are you referring to rpc_clnt_sigmask() ?
i think it isn't safe to assume sa_handler isn't changed during
blocking for lock.  consider CLONE_SIGHAND, for example.

YAMAMOTO Takashi



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
