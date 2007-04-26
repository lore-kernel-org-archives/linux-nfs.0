From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 26 Apr 2007 12:23:04 -0400
Message-ID: <20070426162300.GA12193@salusa.poochiereds.net>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
	<20070426120536.GB24800@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh6kM-0001De-QU
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 09:23:06 -0700
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh6kP-0004It-2m
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 09:23:09 -0700
In-Reply-To: <20070426120536.GB24800@dantu.rdu.redhat.com>
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

On Thu, Apr 26, 2007 at 08:05:37AM -0400, Jeff Layton wrote:
> On Thu, Apr 26, 2007 at 02:56:42PM +1000, Neil Brown wrote:
> > On Wednesday April 25, chuck.lever@oracle.com wrote:
> > > 
> > > Hi Jeff-
> > > 
> > > I don't know much about the export logic, but why not use inode change 
> > > notification instead of time stamps?
> > 
> > inotify is 2.6 only I think.  I'm not sure I want to exclude 2.4
> > people just yet (or do I ??).
> > 
> 
> My feeling is that we should choose the best solution that fits in with
> "current" kernels (for some definition of "current"). Most people running
> old kernels aren't going to be running bleeding-edge nfs-utils anyway...
> 
> 
> > Given that exportfs replaces the file with a new one, would we need to
> > get notification on the directory, or just on the file?  Does it make
> > it more complicated, or easier?
> > 
> 
> I did a little looking at inotify and I think we can monitor more or less
> anything that happens to the file. It might take a bit of experimentation to
> get the right event mask, but it doesn't look to bad.
> 
> > Actually, mountd could open etab and hold it open. auth_reload could
> > stat "/var/lib/nfs/etab" and if it is a different file, then the
> > content is presumably different, while if it is the same file, we can
> > be certain the content is unchanged.
> > 
> > Further, we would be certain only to read each version once - zero
> > risk of re-parsing data when there is no change.
> > 
> > That might be an even better option .... anyone want to code it up??
> > 
> > Or is it wrong to depend on current exportfs behaviour?
> 
> That does seem like the simplest solution (and simple is good). I also don't
> see an issue with depending on current exportfs behavior. If we are going to
> depend on that though, then we should probably include some comments around
> the code that implements that behavior to warn people who might want to change
> it.
> 
> I'll take a crack at coding that up.
> 
> -- Jeff
> 

I've had a look at this, and even took a pretty broad swipe at doing it. The
issue here is that a lot of the existing code is not well geared toward having
an already-open filehandle that gets passed around. Changing this is going to
mean a pretty invasive patch that adds quite a few new functions. I don't feel
confident that this method has enough advantages over your earlier patch to
make this worthwhile.

Neil, what do you think? Should I continue down this road, or should we just
go with what you've already written?

-- Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
