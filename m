From: Neil Brown <neilb@suse.de>
Subject: Re: Status of mount.nfs
Date: Mon, 16 Jul 2007 11:13:14 +1000
Message-ID: <18074.50730.591965.39211@notabene.brown>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAF9S-0007CJ-2v
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 18:13:26 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAF9V-000425-6M
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 18:13:29 -0700
In-Reply-To: message from Steinar H. Gunderson on Sunday July 15
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

On Sunday July 15, sesse@debian.org wrote:
> On Mon, Jul 09, 2007 at 01:17:19PM +1000, Neil Brown wrote:
> > nfs-utils-1.1.0 builds and install mount.nfs by default, and should be
> > used with the new util-linux.
> 
> Just a few experiences with this after a week or so with the new default in
> Debian:

Thanks for sharing.

> 
>  - The new mount is really more picky in several aspects. Most notably, it
>    refuses to mount anything unless rpc.statd is running, which broke our
>    NFS mounting on boot.

Is this simply because you were mounting NFS filesystems before
running statd?  In that case, maybe we should say that it "highlighted
that your NFS mounting on boot was already broken" ?? :-)
If you need to nfsmount '/' or '/var', you should mount them with
"-o nolock"  and then statd won't be needed.

>                          Also, it seems to be less forgiving about portmapper
>    registration; cfs (an encrypted filesystem based off NFS, it seems) sets
>    up a server on port 3049 and expects "-o port=3049,nfsvers=2" to work. The
>    new mount.nfs searches for a portmapper unless the udp option is also
>    correctly set.

I'm a bit confused here.  I would expect that to avoid portmap being
used, you would need to set both 'port' and 'mountport' on the command
line.  It shouldn't have anything to do with whether UDP is set.  Can
you say a bit more about what you discovered here?

>                   I'm slightly surprised at this increase in strictness,
>    given that I thought it was essentially the same code.

It is based on the same code but with quite a number of fixes and
"improvements".  It is entirely possible that some regressions were
introduced, though I tried to do a reasonable amount of testing and
review.


>  - If you forget to install it suid (we strip suid bits automatically) you
>    will of course break user mounts. :-)

and if you forget to install the new man pages, you will have
incomplete documentation :-)
nfs-common  1:1.1.0-9  does not have mount.nfs and umount.nfs man pages.


>  - The umount exit status is broken, which will cause odd failures on umount
>    from the GNOME drive manager (basically, an empty error dialog box). Apply
>    the patch I posted here earlier.

Thanks for this fix.

> 
> I guess that's all the traps I've fell into for now; I hope they'll make it
> easier to make the move for other distributions.

Thanks a lot!

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
