From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Status of mount.nfs
Date: Mon, 16 Jul 2007 11:20:47 +0200
Message-ID: <20070716092047.GA10353@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAMlA-00048s-MR
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 02:20:52 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAMlD-0001I8-2t
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 02:20:56 -0700
In-Reply-To: <18074.50730.591965.39211@notabene.brown>
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

On Mon, Jul 16, 2007 at 11:13:14AM +1000, Neil Brown wrote:
> Is this simply because you were mounting NFS filesystems before
> running statd?  In that case, maybe we should say that it "highlighted
> that your NFS mounting on boot was already broken" ?? :-)

Yes, we were. I'm in the process of patching the boot process now, so you
could probably shed light on a related issue: Do we need to start portmap
before statd or not? The comments in the old code is slightly cryptic :-)

>>                          Also, it seems to be less forgiving about portmapper
>>    registration; cfs (an encrypted filesystem based off NFS, it seems) sets
>>    up a server on port 3049 and expects "-o port=3049,nfsvers=2" to work. The
>>    new mount.nfs searches for a portmapper unless the udp option is also
>>    correctly set.
> I'm a bit confused here.  I would expect that to avoid portmap being
> used, you would need to set both 'port' and 'mountport' on the command
> line.  It shouldn't have anything to do with whether UDP is set.  Can
> you say a bit more about what you discovered here?

Well, I have no idea how these things work at all, I just traced through the
code and saw what would make it work :-) cfs runs as its own NFS daemon, on
port 3049, but does not seem to register with the portmapper. The mount
command given, without "-o udp", gives:

  mount: mount to NFS server 'localhost' failed: RPC Error: Success.

The error seems to originate from probe_nfsport(), which also has a line
saying

  if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
          return 1;

which indicates that if version+protocol+port are all set beforehand, don't
probe -- and indeed, that works. I stopped debugging the issue there.

>>  - If you forget to install it suid (we strip suid bits automatically) you
>>    will of course break user mounts. :-)
> and if you forget to install the new man pages, you will have
> incomplete documentation :-)
> nfs-common  1:1.1.0-9  does not have mount.nfs and umount.nfs man pages.

Thanks, nice catch. I'll be sure to fix that in the next upload.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
