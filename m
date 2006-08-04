From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Processes hanging, directory hanging
Date: Fri, 04 Aug 2006 11:09:52 -0400
Message-ID: <1154704193.4727.11.camel@localhost>
References: <20060801103059.129bc1ac@sup-ceu.wrk.terra.com.br>
	<20060804113838.26ebeed2@sup-ceu.wrk.terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G91JR-00016Q-Ij
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 08:10:09 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G91JQ-0000DT-5V
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 08:10:09 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20060804113838.26ebeed2@sup-ceu.wrk.terra.com.br>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2006-08-04 at 11:38 -0300, Filipe Brandenburger wrote:
> Hello,
> 
> Please, anybody has any hints on this? I'm still with this problem, and
> I still don't have any clues about what to do next...
> 
> Or should I try to post this on other list, like a kernel list? It
> seems to be that the problem is related to the NFS client, but I can't
> be 100% sure of that...

So you upgraded the server, and the clients started to hang. What makes
you think this is a client problem?

Have you tried comparing 'nfsstat' output on the client and server to
see if the server is processing the client requests. A tcpdump to see if
the client is receiving server replies would be useful too.

Also, check what software you upgraded on the server. If it was samba,
and you have oplock support enabled, then the problem could be related
to leases (IIRC there were a few kernel bugs w.r.t. leases that had to
be fixed recently).

Cheers,
 Trond

> Thanks a lot,
> Filipe Brandenburger
> 
> 
> On Tue, 1 Aug 2006 10:30:59 -0300, Filipe Brandenburger
> <branden@terra.com.br> wrote:
> > I'm facing a rather strange situation on a host of mine. I recently
> > upgraded one server software, and after a week running, several
> > processes hang, and including some directories hang.
> > 
> > The processes hang in "D" (disk wait) state. That way, I cannot strace
> > or gdb them to know what they were doing or where they were.
> > 
> > But the strangest thing are directories. Some directories in NFS start
> > to hang, in some way that if I try to "cd" to them or "ls" them
> > (sometimes even TAB complete hangs them) the process hangs, stays in
> > "disk wait" state, and there's no way I can get it back. If I try to
> > strace a process that changes directory to some of these hanged
> > directories, it goes up to the "getent32" and hangs.
> > 
> > I'm using RHEL4, but I tried to upgrade the kernel to the latest
> > release, and the problem happens as well on the latest kernel (which
> > at the time I upgraded was 2.6.17.6).
> > 
> > So I ask:
> > 
> > 1) Do you know of some bug currently unsolved that could cause this?
> > 
> > 2) It seems to me that the problem is in the kernel, but somehow it's
> > being induced by the new version of the application... What could the
> > application be doing wrong to cause such a problem?
> > 
> > 3) How could I try to see what's happening? Since strace and gdb
> > (which are the tools I know) don't work anymore, I couldn't find
> > anything to try to debug the problem... Should I try to dump something
> > from the kernel? Where exactly should I look?
> > 
> > Thanks in advance,
> > Filipe Brandenburger
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys -- and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
