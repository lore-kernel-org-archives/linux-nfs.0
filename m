From: "Carl Spalletta" <cspalletta@gmail.com>
Subject: How does remote NFS open keep local SB in memory after umount?
Date: Fri, 2 Jun 2006 16:12:53 -0400
Message-ID: <69a7202e0606021312t4405a13fre24157c72a9ed26e@mail.gmail.com>
Reply-To: cspalletta@adelphia.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FmG0t-0006Kf-F6
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 13:12:55 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FmG0t-0001Lu-EW
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 13:12:55 -0700
Received: from py-out-1112.google.com ([64.233.166.179])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FmG0t-00069j-2K
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 13:12:55 -0700
Received: by py-out-1112.google.com with SMTP id i49so721047pyi
	for <nfs@lists.sourceforge.net>; Fri, 02 Jun 2006 13:12:53 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

eilb@cse.unsw.edu.au wrote:

>  mount the filesystem over nfs
>  open a file several directories deep. e.g.
>      exec 3< /mnt/cramfs/my/long/path/name/file
>  unmount/remount the file system on the server:
>       exportfs -avu
>       umount /test
>       mount /test
>       exportfs -av

>   try to read from the file

So my question is this: what keeps the superblock of the filesystem
on the server from going away when unmounted (assuming it was the last
instance). I have been unable to locate in the code where any reference
counts pertaining to the superblock are incremented as a result of
opening a file.

Obviously however, something must keep the superblock from going away or
the final read would fail.  Even if by some means the inode was preserved
across mounts the field inode->i_sb would become invalid if the original
SB was destroyed.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
