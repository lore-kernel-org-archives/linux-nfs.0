From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH/RFC Add support for using UUID to
	identify	filesystem in filehandle
Date: Fri, 02 Feb 2007 11:31:30 -0800
Message-ID: <1170444690.5890.33.camel@lade.trondhjem.org>
References: <17859.3893.523905.884732@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HD48J-0008Fh-T5
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 11:31:41 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/UbBGjpAQj5s4VxomzzBeP1rGW6cFmLgA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HD48H-0008IW-Vk
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 11:31:40 -0800
In-Reply-To: <17859.3893.523905.884732@notabene.brown>
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

On Fri, 2007-02-02 at 21:15 +1100, Neil Brown wrote:
> If anyone wants to review these patches, or comment on the design, I'd
> appreciate it....
> 
> The way nfsd has identified filesystems has bothered me for a while.
> 
> The default mechanism is to use the major/minor device number of the
> block device that holds the filesystem.  This doesn't work for
> filesystems without a block device, and has problems if the
> major/minor number changes, as can happen with hardware changes and
> kernel upgrades.
> 
> The alternate introduced some time ago is to explicitly give a number
> to identify each filesystem with fsid=XXX in /etc/exports.  This
> overcomes the above problems but requires manually assigning numbers
> which isn't always ideal.
> 
> What this patch set does is allow you to use a UUID extracted from the
> filesystem with libblkid.
> 
> UUIDs are 16 bytes long and there is not enough room to store that in
> an NFSv2 filehandle (along with identification of the file).
> So for NFSv2 we hash the UUID down to 8 or 4 bytes (using simple xor).
> If the exportpoint is the root of a filesystem, we use an 8 byte
> hash.  If it is lower in the filesystem we use a 4 byte hash and a 4
> byte inode number.
> 
> NFSv3 (and v4) filehandles have lots more room, so there we use the
> full 16byte uuid and an optional 64bit inode number.
> 
> Note that with lots of filesystems exported with NFSv2 there is an
> increased chance of uuid collision.  Don't do that.  Use v3.
> 
> You currently specify the uuid by putting
>    fsuuid
> in the export flags (and you can give an explicit uuid if you want
> to).
> I wonder if I should just over-load fsid, and have
>    fsid=uuid
> (exactly that) to mean use a libblkid uuid, and
>    fsid=xxxxxxxx:xxxxxxxx:xxxxxxxx:xxxxxxxx
> (hex digits for the 'x's) for an explicit uuid.
> I would want to be able to specify both an old fsid and a new uuid (for a
> transition period, to avoid clients suddenly having their file
> handles rejected) so maybe you can just specify "fsid=" twice.
> 
> What do people think?
> 
> It would be nice to be able to call-out to a support program if a given
> uuid didn't match any mounted filesystem.  It could then mount the
> filesystem (maybe from a media-changer) and export it.  I haven't
> implemented that yet.
> 
> Maybe even a call-out the get the uuid of a filesystem that libblkid
> doesn't understand??  Would that be useful?
> 
> Maybe 'fsuuid' should be a default.  If the kernel supports
> uuid-filehandles, mounted should always provide a uuid to the kernel
> and hand out uuid filehandles whenever appropriate.... Or maybe it
> should only default on v3, as on v2 there is a small chance that you
> can break a working setup.
> 
> Thought? comments? Testing?  Review?

I like the idea of using a UUID. That makes server setup infinitely more
easy, and should definitely be the default.

What are the filesystems that support 16 byte UUIDs these days? Should
we also support hashed labels for those that do not?

About the code. It would really be nice if you could avoid all these
open-coded filehandle version numbers and fsid types. Use of a macro or
enum to name them would certainly help the casual code reviewer. Also,
names like "mk_fsid_v7" do tend to confuse. Perhaps something like
mk_fsid_uuid() and mk_fsid_uuid_root_export() (for v6)?

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
