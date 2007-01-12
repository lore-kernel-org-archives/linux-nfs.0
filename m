From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: FileID size with nfsv3
Date: Fri, 12 Jan 2007 16:56:49 -0500
Message-ID: <1168639009.6494.79.camel@lade.trondhjem.org>
References: <OFCF382287.DA9907EB-ON87257261.00753DD3-86257261.0076291E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5UOf-0003cP-OF
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 13:57:14 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+eijgjlRD0WYKRVTtFN3izoVRjY1DgopA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H5UOh-0002jB-1F
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 13:57:15 -0800
To: Christopher T Vogan <cvogan@us.ibm.com>
In-Reply-To: <OFCF382287.DA9907EB-ON87257261.00753DD3-86257261.0076291E@us.ibm.com>
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

On Fri, 2007-01-12 at 15:30 -0600, Christopher T Vogan wrote:
> Thanks Trond,
> So does this mean that Linux on a 64bit system supports 8 byte
> FileID's with NFSv3 now? Is there a time frame when these patches will
> be merged into the mainstream kernel? I am more interested in the
> client as it is connecting to ZFS file sytems on Sun. Snoop tracing
> showed the FileID was 8 bytes. but I got a message on the linux
> system  "Value too large for defined data type". Now this message was
> produced by the running program but i expect that other user tools
> will have the same issue if they cannot handle stat64 calls. 
> How can I get these patches from Dave? 

That sounds like another issue. The fileid is currently converted into a
32-bit hashed value on pure 32-bit systems. That should, IOW, not be the
cause of your EOVERFLOW error.

Are you perhaps using an x86_64 system in 32-bit compatibility mode?
That would already be using 64-bit numbers internally, and would return
EOVERFLOW if you call the 32-bit stat(). David's patches won't help you
here. The only solution would be to ensure that your programs are
LFS-aware, and then to compile them using _FILE_OFFSET_BITS=64.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
