From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Wed, 7 Aug 2002 18:25:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15697.18944.451371.303514@charged.uio.no>
References: <3D513E56.CAF735B6@lmco.com>
	<200208071105.35128.rdieter@math.unl.edu>
	<shsbs8ed4nl.fsf@charged.uio.no>
	<200208071121.04625.rdieter@math.unl.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cTd7-0006Yy-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 09:25:49 -0700
To: Rex Dieter <rdieter@math.unl.edu>
In-Reply-To: <200208071121.04625.rdieter@math.unl.edu>
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

>>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:

     > On Wednesday 07 August 2002 11:17 am, Trond Myklebust wrote:
    >> >>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:
    >> > It depends.  I agree that defaulting to 'sync' is not a bug.
    >> > I do *not* agree that 50k writes is not a bug.
    >>
    >> NFSv2 or v3?

     > I tried primarily v3, but I think I remember testing v2 as
     > well, with similar results.

If you are getting that performance with v3, then it does indeed sound
like a bug somewhere. Try with a stock 2.4.19 kernel instead...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
