From: Simon Nieuviarts <Simon.Nieuviarts@bull.net>
Subject: Re: IO error caused by a race in page cache
Date: Fri, 5 Dec 2003 15:28:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200312051528.31199.Simon.Nieuviarts@bull.net>
References: <200312041457.13791.Simon.Nieuviarts@bull.net> <shswu9c5tq8.fsf@guts.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shswu9c5tq8.fsf@guts.uio.no>
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

On Thursday 04 December 2003 19:21, Trond Myklebust wrote:
> It's a known problem. I've been reviewing the inode metadata code with
> a view to eliminating this type of race. I'll be posting a patch soon...

I searched in the lkml and nfs ml archives on this topic and could not find 
anything. And I still find strange that an EIO error is thrown when the page 
is no more up to date. Do you have pointers to ML threads about these 
topics ?
Cheers,

Simon.



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
