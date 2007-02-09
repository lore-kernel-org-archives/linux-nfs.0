From: Neil Brown <neilb@suse.de>
Subject: Re: PATCH/RFC Add support for using UUID to
	identify	filesystem in filehandle
Date: Fri, 9 Feb 2007 21:42:18 +1100
Message-ID: <17868.20490.168908.226415@notabene.brown>
References: <17859.3893.523905.884732@notabene.brown>
	<1170444690.5890.33.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFTDU-0007ca-Fo
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 02:42:56 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFTDW-0001Xn-6n
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 02:42:58 -0800
In-Reply-To: message from Trond Myklebust on Friday February 2
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

On Friday February 2, trond.myklebust@fys.uio.no wrote:
> 
> I like the idea of using a UUID. That makes server setup infinitely more
> easy, and should definitely be the default.
> 
> What are the filesystems that support 16 byte UUIDs these days? Should
> we also support hashed labels for those that do not?

libblkid seems to find 16byte uuids for
   ext2, ext3, xfs, reiserfs, reiser4, jfs, ocfs, ocfs2

So that excludes FAT (which has a 4 byte uuid), minix, ISO9660, UDF
and some very minor filesystems.

ISO9660 seems to be the only significant one that has a label but not
a uuid.

> 
> About the code. It would really be nice if you could avoid all these
> open-coded filehandle version numbers and fsid types. Use of a macro or
> enum to name them would certainly help the casual code reviewer. Also,
> names like "mk_fsid_v7" do tend to confuse. Perhaps something like
> mk_fsid_uuid() and mk_fsid_uuid_root_export() (for v6)?

Fair comment.  I'll have a look and a think and see what makes it most
readable.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
