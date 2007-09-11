From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd and
	rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 13:33:53 -0400
Message-ID: <1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
	<20070911153742.GG13948@fieldses.org>
	<1189530078.12340.28.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911171621.GI13948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070911171621.GI13948@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2007-09-11 at 13:16 -0400, J. Bruce Fields wrote:
> On Tue, Sep 11, 2007 at 01:01:18PM -0400, David P. Quigley wrote:
> > Another question about the code in general. Why is it that idmapd is
> > using fcntl and user signals to indicate changes to the rpc pipe. Isn't
> > there something else we can use like Inotify or a Netlink socket?
> 
> When a new nfs client is created, a new directory containing several
> files (including the upcall pipe) are created.  The dnotify stuff is
> there so we find out about those new files and directories.  I don't
> know much about netlink--how would it help us there?

I'm not sure that it would be a big help. It seemes that it is a newer
method for transporting data between user and kernel space. There is a
Linux journal article from back in 2005 about them which can be found at
http://www.linuxjournal.com/article/7356. It could remove a dependency
on pipefs, however the only question would be which technology has been
around longer. It would also seem the the method of passing the messages
up to user space would be different. Instead of each client having a
separate file you could have idmapd/doimapd listen on one netlink socket
and messages that come in contain a clientid which the daemon would
associate with the separate clients internally. Again I'm not sure if it
is a big help, but rather a different way of thinking about it that I am
considering. 

> 
> I assume Inotify would work, but I don't see any advantage over dnotify.
> If we didn't leave in some compatability code then it would mean
> dropping support for pre-inotify kernels, wouldn't it?--could be that
> there were only a few of those and that nfsv4 wasn't really usable on
> them anyway (I don't remember), but absent a real motivation to move
> from dnotify to inotify I'd rather not.

That is a good point. Since I'm working on something that will hopefully
be in future kernels I think I can make the assumption of having the
extra features.

> 
> > I am assuming that this is just a result of the code being written
> > before these things were in place. I was originally starting doimapd
> > based on the idmapd source however if it is acceptable to move to one
> > of these other techniques I can switched over to that instead.
> 
> For new stuff I don't think there'd be a problem using something else.
> 
> --b.
