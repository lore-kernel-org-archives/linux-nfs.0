From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: wsize & PAGE_SIZE issues on IA64 clients.
Date: Thu, 27 Mar 2003 16:01:25 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D5546F@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yhJV-0006Wu-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 16:01:41 -0800
To: "Mark Price" <mkprice@us.ibm.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi mark-

> In nfs_updatepage() if the wsize is smaller than the page=20
> size the write=20
> is performed synchronously. It appears though that the block=20
> size is then=20
> reduced further, in this case to 512 bytes. From what I could=20
> work out,=20
> it was cp_new_stat() in linux/fs/stat.c that determined the=20
> new preferred=20
> block size from the remote filesystem.=20
>=20
> On ia32 both the page size and the wsize were 4K, and no=20
> problem was seen.=20
>=20
> Can someone give me rough explanation of why that logic is=20
> used? ie. Why=20
> the page is written synchronously if its smaller than the=20
> page size? and=20
> Why even when its written synchronously the wsize wasn't=20
> used, but the=20
> remote filesystems block size was used?

i can answer the first question.

the problem is that databases need synchronous writes to
always go to disk from the lowest to highest byte; otherwise,
a system restart during a write could result in a torn
database page that can not be detected by some databases.

the Linux NFS client is handed write requests a page at a
time by the VFS layer.  if the NFS client queued pages for
sync writes the way it does for async writes, there is a window
where asynchronous events on the client (like an interrupt,
or the VM decides it needs to reclaim memory, or the fs
syncer runs) can push out incomplete writes to the server.
there is a good chance that even during a small test dd run
with wsize=3D32k, some 32k writes will be broken into smaller
writes on the network.

so the low-risk solution is to make the client always
do sync writes in page-sized pieces; that way, the byte
order at the server is always guaranteed.

i've never seen a problem where the writes are further
reduced in size; i imagine this is an application issue,
not an NFS client issue.

> The fix/workaround was to either increase wsize to 16K, or reduce=20
> PAGE_SIZE to 4K, obviously increasing wsize to 16K makes more sense.

correct.

> However this leads to a problem between Linux clients and=20
> servers where=20
> the maximum supported block size on the server is 8K and the=20
> page size on=20
> the IA64 client is 16K.

correct again.

> Is increasing the maximum blocksize for the server as simple=20
> as changing=20
> NFSSVC_MAXBLKSIZE (linux/include/linux/nfsd/const.h) to 16K=20
> or 32K ? Or is=20
> more porting work required?

neil can answer this with authority, but my impression is
there is more to it than simply bumping NFSSVC_MAXBLKSIZE.


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
