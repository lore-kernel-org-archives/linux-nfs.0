From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: How does remote NFS open keep local SB in memory
	after	umount?
Date: Fri, 02 Jun 2006 16:16:53 -0400
Message-ID: <1149279414.5621.56.camel@lade.trondhjem.org>
References: <69a7202e0606021312t4405a13fre24157c72a9ed26e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FmG5E-0006mM-Si
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 13:17:24 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FmG5E-0001nI-Su
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 13:17:24 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FmG54-00079E-Be
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 13:17:24 -0700
To: cspalletta@adelphia.net
In-Reply-To: <69a7202e0606021312t4405a13fre24157c72a9ed26e@mail.gmail.com>
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

On Fri, 2006-06-02 at 16:12 -0400, Carl Spalletta wrote:
> eilb@cse.unsw.edu.au wrote:
> 
> >  mount the filesystem over nfs
> >  open a file several directories deep. e.g.
> >      exec 3< /mnt/cramfs/my/long/path/name/file
> >  unmount/remount the file system on the server:
> >       exportfs -avu
> >       umount /test
> >       mount /test
> >       exportfs -av
> 
> >   try to read from the file
> 
> So my question is this: what keeps the superblock of the filesystem
> on the server from going away when unmounted (assuming it was the last
> instance). I have been unable to locate in the code where any reference
> counts pertaining to the superblock are incremented as a result of
> opening a file.
> 
> Obviously however, something must keep the superblock from going away or
> the final read would fail.  Even if by some means the inode was preserved
> across mounts the field inode->i_sb would become invalid if the original
> SB was destroyed.

The struct file carries a reference to the vfsmount structure.

Cheers,
  Trond



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
