From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS as a Cluster File System.
Date: Sun, 12 Jan 2003 22:29:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15905.56910.633666.132328@charged.uio.no>
References: <F100FR0rmTIVvLVKi3s0000ec53@hotmail.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alanr@unix.sh,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18XpgB-0002MT-00
	for <nfs@lists.sourceforge.net>; Sun, 12 Jan 2003 13:30:03 -0800
To: "Lorn Kay" <lorn_kay@hotmail.com>
In-Reply-To: <F100FR0rmTIVvLVKi3s0000ec53@hotmail.com>
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

>>>>> " " == Lorn Kay <lorn_kay@hotmail.com> writes:

     > Meaning if you don't lock a file and just read it you may not
     > see the what another client has written to it, or is that not
     > an issue because the other client will have locked and then
     > unlocked the file when it is done making changes?

Meaning that unless *all* clients lock the file prior to reading or
writing from it (and then unlock it when done), there will be
caching inconsistencies.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
