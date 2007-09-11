From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd
	and	rework gssd and idmapd to use the new xlog logging
	infrastructure.
Date: Tue, 11 Sep 2007 11:37:42 -0400
Message-ID: <20070911153742.GG13948@fieldses.org>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV7o6-0006ZM-Rw
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:37:43 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IV7oA-0003ZK-Bw
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:37:47 -0700
In-Reply-To: <4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
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

On Tue, Sep 11, 2007 at 11:28:48AM -0400, Kevin Coffman wrote:
> On 9/11/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> > On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > > Could you point me to the second in gssd that is doing this? It might be
> > > better to use the print statements in a saner way.
> > >
> > > Dave
> >
> > Agreed.  The cuprit is print_hexl() in svcgssd_proc.c, which currently
> > calls printerr() multiple times.  I'll look to see if I can find other
> > instances that might be depending on the line acculation of printerr.
> 
> The qword_* functions in cachio.c also currently use this.

Actually, we only have two print_hexl's, both dumping the data that was
read from the kernel's null upcall pipe on the server side.

I think those could probably go.  Kevin, have you used them recently?
There's also always the option of running the program under strace with
-s9999 to see all the read and write data, though that may not be as
convenient.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
