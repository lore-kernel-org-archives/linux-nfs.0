From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RPC: Unable to allocate resbuf from cache! - revisited
Date: 06 Jan 2003 09:38:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslm1ysmfd.fsf@charged.uio.no>
References: <3E15A708.50102@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VSm5-0003Yp-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 00:38:21 -0800
To: Dan Yocum <yocum@fnal.gov>
In-Reply-To: <3E15A708.50102@fnal.gov>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " =3D=3D Dan Yocum <yocum@fnal.gov> writes:

     > Hi all, Looking back at the archives
     > (http://marc.theaimsgroup.com/?t=3D101707335800002&r=3D1&w=3D2) I see
     > that you (Trond) say that these copious "RPC: Unable..."=20
     > messages shouldn't be a problem.  Could they be a problem?


     > The reason I ask is, occassionally, we're getting these strange
     > files created with 0 size, date, and some gobble-dee-gook
     > names, and they just so happen to show up when we get this
     > error message in the logs.  Here's what one looks like:


     > bash-2.04$ ls -l |egrep -v '(fit|ps|fp|mem)' total 5742612
     > -rwxr-xr-x 1 jen_a sdss 0 Dec 31 1969 :N=A8TL8=D5 =E4=F0=FF=FF=EB=FE=
=FF=F5@ =A6,

     > The rest of the files are OK, but this is slightly
     > disconcerting.

That's totally unrelated to the above message, and looks rather like a
server bug. Is the server also 2.4.18+XFS?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
