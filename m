From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	server 192.168.0.1 with error
	121
Date: Sat, 22 Sep 2007 14:52:27 -0400
Message-ID: <20070922185227.GD403@fieldses.org>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
	<1190048861.6700.105.camel@heimdal.trondhjem.org>
	<1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
	<1190060733.5541.14.camel@fry.u7.se>
	<1190396486.6690.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZA5h-0000PN-5t
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 11:52:33 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZA5k-0006GE-Vh
	for nfs@lists.sourceforge.net; Sat, 22 Sep 2007 11:52:38 -0700
In-Reply-To: <1190396486.6690.4.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Sep 21, 2007 at 01:41:26PM -0400, Trond Myklebust wrote:
> So, it looks as if the server is hanging in laundromat_main, and that is
> preventing the client from registering a setclientid.
> 
> Bruce?

No idea.  Sorry, just catching up here....  This is 100% reproduceable?
Would it be possible to see a network trace?  (tcpdump -s0 -wtmp.pcap,
then send me tmp.pcap.  Ideally it should cover the whole time from the
initial mount to the first symptoms of the problem).

And as always it might be worth trying the latest kernel, though on a
quick skim through git I can't see anything obviously related.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
