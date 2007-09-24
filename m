From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	server 192.168.0.1 with error
	121
Date: Mon, 24 Sep 2007 18:20:26 -0400
Message-ID: <20070924222026.GP26387@fieldses.org>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
	<1190048861.6700.105.camel@heimdal.trondhjem.org>
	<1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
	<1190060733.5541.14.camel@fry.u7.se>
	<1190396486.6690.4.camel@heimdal.trondhjem.org>
	<20070922185227.GD403@fieldses.org>
	<1190668767.3958.9.camel@fry.u7.se>
	<20070924220247.GO26387@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jonas Jonsson <jonas@websystem.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZwI3-0001eF-Gi
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 15:20:31 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZwI6-0005no-HB
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 15:20:34 -0700
In-Reply-To: <20070924220247.GO26387@fieldses.org>
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

On Mon, Sep 24, 2007 at 06:02:47PM -0400, bfields wrote:
> OK, thanks!  Looks like it starts out fairly normally, then at packet
> 824 it gets into this SETCLIENTID->NFS4ERR_RESOURCE loop.  I'm not sure
> how that happened.
> 
> I'm a little unclear whether RESOURCE is supposed to be a temporary
> error or not, but in either case retrying it indefinitely with no delay
> is probably a bad idea.  But I guess that's not the bug.  OK, I'll try
> to figure out what lead up to that....

Oh, good grief, we're lame.  Could you check your .config--is it
possible you have CONFIG_CRYPTO_MD5 turned off?  If so, could you verify
that turning it on fixes the problem?

The recovery code is being silly and returning RESOURCE if it can't load
that crypto module.  Current upstream doesn't allow building v4 without
MD5, so you probably won't be able to reproduce the problem on the
latest kernel.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
