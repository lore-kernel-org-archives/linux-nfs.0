From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: FileID size with nfsv3
Date: Fri, 12 Jan 2007 15:42:37 -0500
Message-ID: <1168634557.6494.52.camel@lade.trondhjem.org>
References: <OF3AC591FD.96801C6A-ON87257261.005FEDEB-86257261.00603911@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5TEl-0004ZN-Sc
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 12:42:56 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+DVx2qElVmbMnpM5LgaFz07FnWweI+gpE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H5TEm-0003XY-Au
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 12:42:57 -0800
To: Christopher T Vogan <cvogan@us.ibm.com>
In-Reply-To: <OF3AC591FD.96801C6A-ON87257261.005FEDEB-86257261.00603911@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-01-12 at 11:31 -0600, Christopher T Vogan wrote:
> 
> I had a question regarding NFSv3 Client and server but was not sure
> who to ask.
> The NFSv3 RFC states that NFSv3 should support 8 byte FILEID's. Does
> Linux
> support 8 byte FILEID's for NFSv3? It seems that most commands do
> support the use of large FileID's but gcc seems to have a problem. 
> 
> This is what I see in the RFC1813
> File attribute changes from NFSv2.
> The size and fileid fields have been widened to eight-byte unsigned
> integers from four-byte integers.

We don't currently export 64-bit inode numbers to userland on 32-bit
platforms because the code to allow getdents64() and stat64() to deal
with them was only recently merged into the kernel (as of 2.6.19).

I believe that David Howells does have patches that allows NFS to make
use of this new functionality, but he hasn't asked me to push them to
Linus yet. I'm not sure why.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
