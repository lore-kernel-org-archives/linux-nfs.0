From: Peter Astrand <astrand@lysator.liu.se>
Subject: Re: Re: NFS retry on disconnection
Date: Tue, 14 May 2002 10:38:58 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0205141035150.22074-100000@sofie.lambo.student.liu.se>
References: <shssn4vf8jo.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a88.lambo.student.liu.se ([130.236.229.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Xpn-0005Ci-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 01:39:03 -0700
Received: from localhost (localhost [127.0.0.1])
	by a88.lambo.student.liu.se (Postfix) with ESMTP id 4F9FCCF3E
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 10:38:58 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <shssn4vf8jo.fsf@charged.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>      > One thing that keeps annoying me is that "intr" only allows
>      > interrupting the file operation when a major timeout happens. I
> 
> Nope. Major, minor, it all goes through the same code and both can be
> interrupted. 

Does this mean that the man page nfs(5) is incorrect? It says:

"intr 

If an NFS file operation has a major timeout and it is hard mounted, then
allow signals to interupt the file operation and cause it to return EINTR
to the calling program."

> If, say, they are both waiting to read data from the same page, then
> only one process actually does the RPC call. The VFS/MM layers will
> put the other process to sleep in the global function 'lock_page()'.
> That unfortunately means that it cannot interrupt, since 'lock_page()'
> does not do interruptible sleeps.

I see. And this is not possible to change?


-- 
/Peter Åstrand <astrand@lysator.liu.se>




_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
