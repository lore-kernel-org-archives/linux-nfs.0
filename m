From: Neil Brown <neilb@suse.de>
Subject: Re: Status of mount.nfs
Date: Mon, 16 Jul 2007 20:15:19 +1000
Message-ID: <18075.17719.855332.259470@notabene.brown>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IANbw-00025n-0Q
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 03:15:24 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IANbz-0002mo-6u
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 03:15:27 -0700
In-Reply-To: message from Steinar H. Gunderson on Monday July 16
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

On Monday July 16, sesse@debian.org wrote:
> On Mon, Jul 16, 2007 at 11:13:14AM +1000, Neil Brown wrote:
> > Is this simply because you were mounting NFS filesystems before
> > running statd?  In that case, maybe we should say that it "highlighted
> > that your NFS mounting on boot was already broken" ?? :-)
> 
> Yes, we were. I'm in the process of patching the boot process now, so you
> could probably shed light on a related issue: Do we need to start portmap
> before statd or not? The comments in the old code is slightly cryptic :-)

Yes.  Portmap should be one of the first things started after basic
networking is up.  You might even be able to start it before that, but
I'm not sure.  You need it before any RPC service which includes
statd, lockd, nfsd, ypbind, ...
You can mount an NFS filesystem with '-o nolocks' before portmap, but
that it about all.

> 
> >>                          Also, it seems to be less forgiving about portmapper
> >>    registration; cfs (an encrypted filesystem based off NFS, it seems) sets
> >>    up a server on port 3049 and expects "-o port=3049,nfsvers=2" to work. The
> >>    new mount.nfs searches for a portmapper unless the udp option is also
> >>    correctly set.
> > I'm a bit confused here.  I would expect that to avoid portmap being
> > used, you would need to set both 'port' and 'mountport' on the command
> > line.  It shouldn't have anything to do with whether UDP is set.  Can
> > you say a bit more about what you discovered here?
> 
> Well, I have no idea how these things work at all, I just traced through the
> code and saw what would make it work :-) cfs runs as its own NFS daemon, on
> port 3049, but does not seem to register with the portmapper. The mount
> command given, without "-o udp", gives:
> 
>   mount: mount to NFS server 'localhost' failed: RPC Error: Success.
> 
> The error seems to originate from probe_nfsport(), which also has a line
> saying
> 
>   if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
>           return 1;
> 
> which indicates that if version+protocol+port are all set beforehand, don't
> probe -- and indeed, that works. I stopped debugging the issue there.

Hmmm.... That code looks a little odd.  If you say you want udp, it
will still probe for tcp first.  That doesn't hurt as UDP and TCP
always use the same port: 2049.  But it is still odd.  I wonder if it
is needed at all.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
