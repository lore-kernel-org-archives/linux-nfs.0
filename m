From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS as a Cluster File System.
Date: 10 Jan 2003 16:01:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3co1kq1e.fsf@charged.uio.no>
References: <F155FnqdR2xuRoAnbsZ00020983@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alanr@unix.sh,  nfs@lists.sourceforge.net,  linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18X0eq-0000VC-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 07:01:16 -0800
To: "Lorn Kay" <lorn_kay@hotmail.com>
In-Reply-To: <F155FnqdR2xuRoAnbsZ00020983@hotmail.com>
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

    >> NFS V3 and before have problems with "cache coherency".  That
    >> is, the different nodes in the cluster are not guaranteed to
    >> see the same contents.

     > I think this can be resolved with the "noac" mount option
     > (prior to V4).

Nope. It can only be resolved using file locking.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
