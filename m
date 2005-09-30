From: Robert Finch <Rob.Finch@loudeye.com>
Subject: NFS + multiple mount --bind problem
Date: Fri, 30 Sep 2005 15:40:15 -0700
Message-ID: <20050930224015.GH28846@loudeye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EMAuz-0008LR-Nd
	for nfs@lists.sourceforge.net; Sun, 02 Oct 2005 13:58:45 -0700
Received: from mail01.loudeye.com ([64.85.69.190] helo=EX01.int.loudeye.com)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1ELTZv-0002lu-4E
	for nfs@lists.sourceforge.net; Fri, 30 Sep 2005 15:42:09 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I'm having a problem with using an NFS mounted filesystem, in conjection with multiple mount --bind's exporting a specific directory within that mount to a chroot jail. Basically it looks like this;

nfsserver:/mnt/foo/customer1
nfsserver:/mnt/foo/customer2

nfsclient mounts nfsserver:/mnt/foo to nfsclient:/mnt/client

I then do

mount --bind /mnt/client/customer1 /home/customer1
mount --bind /mnt/client/customer2 /home/customer2

Inside their chroot jail. This all works fine for a while, but consistently since I've implemented it I am getting stale NFS filehandle messages, usually once a day, which prevent most operations over the mount. One of the more odd things is, I can still do things like

`cat /home/customer1/randomfile`

sucessfully, but doing an `ls` in that directory returns the stale filehandle message. It's breaking the ability for ssh keys to be read out of authorized_keys file.

I've searched around quite a bit and this link seems to have information on why it's happening; http://lkml.org/lkml/2003/12/3/271 - specifically

>"mount --bind" certainly has a good chance of confusing nfsd.
>If you --bind mount the root of the filesystem somewhere else and
>export that, then the filehandles generated will be exactly the same
>and nfsd cannot know whether a request is indented for one mountpoint
>or the other.
>When using --bind, it is best to give an 'fsid=' option in
>/etc/exports so that nfsd can use that to differentiate the mount
>points.

However since there is only one export I don't think giving the fsid= option will help (I have tried it).

Perhaps the workaround solution is to implicitly export each one of these directories and mount each one on the client machine, but that kind of seems like a lot of extra overhead to me, having to keep stat on different mounts. Automount might help with that, though, I suppose.

Relevant information;

nfsv3 on client/server
SuSE SLES 9 kernel 2.6.8 on server (ugh I know)
Debian 3.1 kernel 2.4.29 on client

Export on server looks like;

/mnt/terra10  10.200.2.14(rw,root_squash,sync,fsid=11)
/mnt/terra11  10.200.2.14(rw,root_squash,sync,fsid=14)

I've tried a variety of export options as well.

Any thoughts or even wild speculation? :-)


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
