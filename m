From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: IO error caused by a race in page cache
Date: 04 Dec 2003 13:21:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswu9c5tq8.fsf@guts.uio.no>
References: <200312041457.13791.Simon.Nieuviarts@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Simon Nieuviarts <Simon.Nieuviarts@bull.net>
In-Reply-To: <200312041457.13791.Simon.Nieuviarts@bull.net>
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

>>>>> " " == Simon Nieuviarts <Simon.Nieuviarts@bull.net> writes:


     > Now, my tests go to completion, and the warning is displayed 6
     > or 7 times.  I know it is no more time to make changes to the
     > VFS, and I am not sure it is the right fix...  What do you
     > think about this bug ?  Cheers,

It's a known problem. I've been reviewing the inode metadata code with
a view to eliminating this type of race. I'll be posting a patch soon...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
