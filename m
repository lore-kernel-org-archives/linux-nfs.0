From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: pf: to scrub or not to scrub?
Date: 28 Jul 2002 17:15:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <967.001033905213$1027869504@news.gmane.org>
References: <Pine.GSO.4.33.0207241828330.586-100000@loogie.intranet.csupomona.edu>
	<20020725094904.GE8969@skywalker.bsws.de>
	<20020725183112.GA4708@esme.xs4all.nl> <20020725190243.GB8076@w4g.org>
	<20020727232451.GG26763@han.myip.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: han@mijncomputer.nl, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: misc@openbsd.org
In-Reply-To: <20020727232451.GG26763@han.myip.org>
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

>>>>> " " == han  <han@mijncomputer.nl> writes:

     > Hi, I run an OpenBSD (current) nfs server with a linux nfs
     > client (2.4.19-rc3-ac3) and if I turn on the scrub feature
     > (reassemble all fragments) of the OpenBSD firewall I get into
     > trouble with the nfs-client not being able anymore to
     > connect. Perhaps this is something that can be improved in the
     > nfs code. This is not urgent since I can tell the firewall to
     > only pay attention to fragments from the external interface.

The Linux NFS client just uses a standard UDP socket (Nothing up my
sleeve). No special flags are set beyond those which you will get
from using the standard call 'socket(PF_INET, SOCK_DGRAM, 0)'.

Mind explaining exactly what is causing the OpenBSD 'scrub' filter to
fail to pass these packets?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
