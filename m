From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
	kernel
Date: Tue, 11 Jan 2005 15:10:45 -0500
Message-ID: <1105474246.11430.1.camel@lade.trondhjem.org>
References: <41DD8403.7030601@RedHat.com>
	 <1105118040.10979.70.camel@lade.trondhjem.org>
	 <41E42AD7.3030303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CoSM5-0007vQ-Pf
	for nfs@lists.sourceforge.net; Tue, 11 Jan 2005 12:11:05 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CoSM4-0000FP-8h
	for nfs@lists.sourceforge.net; Tue, 11 Jan 2005 12:11:05 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41E42AD7.3030303@RedHat.com>
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

ty den 11.01.2005 Klokka 14:36 (-0500) skreiv Steve Dickson:

> >Firstly, how is "cl_intr" preventing core dumps? Normally, we should be
> >masking all signals except SIGKILL, SIGINT and SIGQUIT. I can see that
> >masking SIGINT and SIGQUIT might be useful here, but not SIGKILL...
> >  
> >
> Because __rpc_execute() notices that signalled() is set and aborts the 
> write by
> returning -ERESTARTSYS makes the core dumping code stop dumping.

Err... That's what the sigmask is for. signalled() only looks at those
signals that are enabled by the sigmask.

> >Secondly: Why not do all this in rpc_clnt_sigmask()?
> >  
> >
> I looked at that.... but I really was not sure if could hack it up
> to turn off signalled() and plus I was sure how I could turn
> signalled() back on at the end of the write.... The way I did
> just seemed less risky and seem to work...

See above.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
