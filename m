From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
	kernel
Date: Fri, 07 Jan 2005 12:14:00 -0500
Message-ID: <1105118040.10979.70.camel@lade.trondhjem.org>
References: <41DD8403.7030601@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cmxgk-000368-HL
	for nfs@lists.sourceforge.net; Fri, 07 Jan 2005 09:14:14 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cmxgh-0003iG-7C
	for nfs@lists.sourceforge.net; Fri, 07 Jan 2005 09:14:13 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41DD8403.7030601@RedHat.com>
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

to den 06.01.2005 Klokka 13:31 (-0500) skreiv Steve Dickson:

> Comments... Suggestions... Crimes against humanity that I'm committing???


Firstly, how is "cl_intr" preventing core dumps? Normally, we should be
masking all signals except SIGKILL, SIGINT and SIGQUIT. I can see that
masking SIGINT and SIGQUIT might be useful here, but not SIGKILL...

Secondly: Why not do all this in rpc_clnt_sigmask()?

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
