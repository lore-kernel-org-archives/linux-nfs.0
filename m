From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
	kernel
Date: Tue, 11 Jan 2005 16:59:05 -0500
Message-ID: <1105480745.11430.56.camel@lade.trondhjem.org>
References: <41DD8403.7030601@RedHat.com>
	 <1105118040.10979.70.camel@lade.trondhjem.org>
	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>
	 <41E43DE1.5080703@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CoU2q-00045p-NU
	for nfs@lists.sourceforge.net; Tue, 11 Jan 2005 13:59:20 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CoU2p-0000ZV-Pf
	for nfs@lists.sourceforge.net; Tue, 11 Jan 2005 13:59:20 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41E43DE1.5080703@RedHat.com>
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

ty den 11.01.2005 Klokka 15:58 (-0500) skreiv Steve Dickson:

> hmm... I'll admit kernel signal process is not an area I've ventured 
> into much so
> correct me if I'm wrong.... But if SIGKILL is masked off, would that stop
> the process from getting the signal and in turn stop the core dropping 
> as well???

Yes, but I'm not sure that it makes sense to mask off SIGKILL as that
makes core dumping completely uninterruptible. People do expect "kill
-9" to always work when the "intr" flag is set.

You should, however, mask off all other signals, including SIGINT and
SIGQUIT. The latter two (+ sigkill) are the only ones that
rpc_clnt_sigmask() does not currently mask out when "intr" is set.

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
