From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Wed, 7 Aug 2002 11:05:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208071105.35128.rdieter@math.unl.edu>
References: <3D513E56.CAF735B6@lmco.com> <200208071037.39377.rdieter@math.unl.edu> <shsfzxqd5oy.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cTJZ-0008EH-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 09:05:37 -0700
Received: from duran.unl.edu (IDENT:6eqnCi5y5Xp/mu9ymlfqxr3rJHwq1jU5@duran.unl.edu [129.93.50.93])
	by mathstat.unl.edu (8.9.3/8.9.3) with ESMTP id LAA05820
	for <nfs@lists.sourceforge.net>; Wed, 7 Aug 2002 11:05:35 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <shsfzxqd5oy.fsf@charged.uio.no>
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

On Wednesday 07 August 2002 10:55 am, Trond Myklebust wrote:
> >>>>> " " =3D=3D Rex Dieter <rdieter@math.unl.edu> writes:
>      > The Hit is big and bad.  When using the default NFS export
>      > options (in particular sync), I see NFS write performance of
>      > ~50k with the 2.4.18-5 kernels.  When set async, performance
>      > comes back up to par.  I can give you the bugzilla # I reported
>      > it under, if you like.

> That is *not* a bug.=20

It depends.  I agree that defaulting to 'sync' is not a bug.  I do *not*=20
agree that 50k writes is not a bug.

-- Rex


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
