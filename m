From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Readdirplus compatibility fix for IRIX server
Date: Wed, 10 Dec 2003 19:48:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16343.48833.339487.248965@guts.uio.no>
References: <3FD7A2A1.1030109@RedHat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUEzz-0001Vr-60
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 16:48:11 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUEzy-00014M-Op
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 16:48:10 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3FD7A2A1.1030109@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > It seems IRIX servers fails READDIRPLUS calls with
     > NFSERR_TOOSMALL when the cookie does not exist which is *not*
     > the case with "normal" READDIR calls...  Cute uh...

Uhhh... Quite...

Now it is possible that we ought to fall back to using READDIR when
the server returns an NFSERR_TOOSMALL error, but the above blatant
server bug sure as hell isn't the reason. Rather it is the fact that
READDIR requires a smaller buffer, and so may help us recover from
*real* NFSERR_TOOSMALL errors.

     > Since the server is telling client there is no more data, is
     > there really a need for that final readdir RPC? Now if there is
     > a cookie mismatch and the EOF bit is not set then I (guess) can
     > see the need for another RPC... But in the "normal" case it
     > appears that extra RPC is not needed....  (Note: This extra RPC
     > happens with both READDIR and READDIRPLUSs it does affect the
     > stock kernels and it seems to happen with non-linux servers,
     > like netapp and IRIX)

     > The attached patch eliminates the extra RPC (when not needed)
     > which in turn takes care of the IRIX incompatibly problem....

     > Comments?

You are misinterpreting. entry->eof will *always* be set in this case,
because readdir_search_pagecache() will have had to iterate through
the entire page cache in order to determine that it could not find the
cookie.

The point is that when you do 'rm -rf', you are deleting files as you
iterate through the directory, and so the file entries are
disappearing from the page cache too. We use the readdir entry's
cookie as our file pointer, hence when that entry disappears from
underneath us, we lose our 'place marker' in the page cache.

At that point we have to ask the server for help: since the cookie can
be presented to the server in order to have it return the
corresponding next entry, we are thus able to recover.  Your patch is
merely short-circuiting that recovery mechanism.

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
