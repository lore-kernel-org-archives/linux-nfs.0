From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd
 and rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 14:39:05 -0400
Message-ID: <20070911143905.5f478095.jlayton@redhat.com>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
	<20070911153742.GG13948@fieldses.org>
	<1189530078.12340.28.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911171621.GI13948@fieldses.org>
	<1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVAdh-0003Gs-0j
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 11:39:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVAdk-0005NF-8R
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 11:39:13 -0700
In-Reply-To: <1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
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

On Tue, 11 Sep 2007 13:33:53 -0400
"David P. Quigley" <dpquigl@tycho.nsa.gov> wrote:

> On Tue, 2007-09-11 at 13:16 -0400, J. Bruce Fields wrote:
> > On Tue, Sep 11, 2007 at 01:01:18PM -0400, David P. Quigley wrote:
> > > Another question about the code in general. Why is it that idmapd is
> > > using fcntl and user signals to indicate changes to the rpc pipe. Isn't
> > > there something else we can use like Inotify or a Netlink socket?
> > 
> > When a new nfs client is created, a new directory containing several
> > files (including the upcall pipe) are created.  The dnotify stuff is
> > there so we find out about those new files and directories.  I don't
> > know much about netlink--how would it help us there?
> 
> I'm not sure that it would be a big help. It seemes that it is a newer
> method for transporting data between user and kernel space. There is a
> Linux journal article from back in 2005 about them which can be found at
> http://www.linuxjournal.com/article/7356. It could remove a dependency
> on pipefs, however the only question would be which technology has been
> around longer. It would also seem the the method of passing the messages
> up to user space would be different. Instead of each client having a
> separate file you could have idmapd/doimapd listen on one netlink socket
> and messages that come in contain a clientid which the daemon would
> associate with the separate clients internally. Again I'm not sure if it
> is a big help, but rather a different way of thinking about it that I am
> considering. 
> 

There's a somewhat related issue to this as well. I've started looking
over what it would take to add kerberos support to CIFS. It would be
*really* nice to be able to use the same gssd that NFS is using and
just massage that data for CIFS.

Doing this with the current rpc_pipefs based daemon is going to be
problematic though. I don't think we want CIFS to be dependent on RPC,
and ripping that code out of the sunrpc module would be a pain.

Moving gssd to netlink sockets might neatly sidestep that problem
altogether...

> > 
> > I assume Inotify would work, but I don't see any advantage over dnotify.
> > If we didn't leave in some compatability code then it would mean
> > dropping support for pre-inotify kernels, wouldn't it?--could be that
> > there were only a few of those and that nfsv4 wasn't really usable on
> > them anyway (I don't remember), but absent a real motivation to move
> > from dnotify to inotify I'd rather not.
> 
> That is a good point. Since I'm working on something that will hopefully
> be in future kernels I think I can make the assumption of having the
> extra features.
> 
> > 
> > > I am assuming that this is just a result of the code being written
> > > before these things were in place. I was originally starting doimapd
> > > based on the idmapd source however if it is acceptable to move to one
> > > of these other techniques I can switched over to that instead.
> > 
> > For new stuff I don't think there'd be a problem using something else.
> > 
> > --b.
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
