From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Readdirplus compatibility fix for IRIX server
Date: Thu, 11 Dec 2003 13:03:18 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FD7D066.4084EF2@melbourne.sgi.com>
References: <3FD7A2A1.1030109@RedHat.com> <16343.48833.339487.248965@guts.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUGAw-0007ij-C3
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 18:03:34 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUGAw-0004ls-5l
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 18:03:34 -0800
To: trond.myklebust@fys.uio.no
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

Trond Myklebust wrote:
> 
> >>>>> " " == Steve Dickson <SteveD@redhat.com> writes:
> 
>      > It seems IRIX servers fails READDIRPLUS calls with
>      > NFSERR_TOOSMALL when the cookie does not exist which is *not*
>      > the case with "normal" READDIR calls...  Cute uh...
> 
> Uhhh... Quite...
> 
> [...] the above blatant
> server bug [...]

I've raised an SGI bug report for this.  I expect it to be fixed in IRIX 6.5.24.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
