From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
	kernel
Date: Thu, 13 Jan 2005 21:57:14 -0500
Message-ID: <1105671434.20314.3.camel@lade.trondhjem.org>
References: <41DD8403.7030601@RedHat.com>
	 <1105118040.10979.70.camel@lade.trondhjem.org>
	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>
	 <41E43DE1.5080703@RedHat.com>
	 <1105480745.11430.56.camel@lade.trondhjem.org> <41E569E3.20206@RedHat.com>
	 <1105554342.23943.1.camel@lade.trondhjem.org> <41E5767F.40204@RedHat.com>
	 <1105576681.14443.100.camel@lade.trondhjem.org>
	 <41E67F38.6060203@RedHat.com>  <41E6EA19.4030806@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpHeQ-0006g5-6Y
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 18:57:26 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CpHeP-0000ly-Lh
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 18:57:26 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41E6EA19.4030806@RedHat.com>
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

to den 13.01.2005 Klokka 16:37 (-0500) skreiv Steve Dickson:

> after further review.... it seems the reason your patch works on a 
> 2.4.28 kernel, is
> because signalled() never returns true, even when the process is sent 
> the SIGSEGV signal. Why signalled() never returns true, I don't know.... 
> but the
> reason your patch did not work on a RHEL3 kernel is because signalled() 
> does
> return true and calls to recalc_sigpending() do not reset that pending 
> signal....
> which seems to be a bug in the NTPL-related code.... code that is not in the
> 2.4.28 kernel....

recalc_sigpending() failing to honour the sigmask sounds like a pretty
major bug! Is there no way you can backport some of the 2.6 signal code
or something like that in order to work around it?

It sounds to me as if that bug will affect more than just coredumps...

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
