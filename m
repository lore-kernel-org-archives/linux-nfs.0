From: Christoph Hellwig <hch@infradead.org>
Subject: Re: NFSv4 pseudo filesystem
Date: Fri, 10 May 2002 19:18:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <abh301$cra$2@main.gmane.org>
References: <Pine.SOL.4.44.0205101340370.27306-100000@mspacman.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from imladris.infradead.org ([194.205.184.45] helo=phoenix.infradead.org)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 176Eye-0000ed-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 11:18:49 -0700
To: "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: <Pine.SOL.4.44.0205101340370.27306-100000@mspacman.gpcc.itd.umich.edu>; from kmsmith@umich.edu on Fri, May 10, 2002 at 02:12:12PM -0400
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

On Fri, May 10, 2002 at 02:12:12PM -0400, Kendrick M. Smith wrote:
> Background: In NFSv2/v3, the server's exports are more or less independent
> of each other, and must be mounted seperately by the client.  NFSv4
> introduced the requirement that the server must export a 'root filehandle'
> (which must be a directory), and that all the exports be obtainable by
> browsing the subtree rooted at the root filehandle.  In other words, the
> server must present the client with ficticious directories, which live
> above the exports and serve to tie them all together into one tree.  (The
> term "pseudo filesystem" is used to refer to this collection of ficticious
> directories.)

Create the NFSv4 daemons using clone(.., CLONE_NAMESPACE, ..) and build
your own per-process namespace to fit the exports.


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
