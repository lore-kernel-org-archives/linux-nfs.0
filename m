From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFSv4 pseudo filesystem
Date: Sat, 11 May 2002 16:31:11 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15580.47791.999102.980645@notabene.cse.unsw.edu.au>
References: <Pine.SOL.4.44.0205101340370.27306-100000@mspacman.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    <linux-fsdevel@vger.kernel.org>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 176QPu-0006IA-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 23:31:42 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <kmsmith@umich.edu>) (for <nfs@lists.sourceforge.net>)
	(for <linux-fsdevel@vger.kernel.org>) (for <nfsv4-wg@citi.umich.edu>)
	By tone With Smtp ; Sat, 11 May 2002 16:31:32 +1000
To: "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: message from Kendrick M. Smith on Friday May 10
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

On Friday May 10, kmsmith@umich.edu wrote:
> 
>   Proposal 3: Build up the pseudofs inside the 2.5 'nfsd' filesystem,
>   say in a directory nfsd/pseudofs which is created when the nfsd
>   filesystem is mounted.  The exportfs utility would be responsible
>   for creating the necesary subdirectories, then hanging the exports
>   off the leaves with mount --bind, before starting nfsd.
> 
> As I see it, the disadvantage of proposal 3 is that it is a little
> tricky to construct persistent filehandles ("persistent" in the sense
> that an old filehandle is still recognize after the server is rebooted).
> One solution would be to use an MD5 or SHA hash of the pathname as the
> filehandle.  The hash could be computed in userspace and passed into
> the kernel somehow.

I would go for 3, and don't care about persistent file handles.  Just
use volatile filehandles for this bit of the namespace.

NeilBrown

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
