From: "Igor Rychkov" <rych@chem.scphys.kyoto-u.ac.jp>
Subject: RE: NFS digest, Vol 1 #1212 - 9 msgs
Date: Sat, 2 Nov 2002 10:42:20 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ACEAKKINMBBEGMOOHHNAGEEECGAA.rych@chem.scphys.kyoto-u.ac.jp>
References: <5CA6F03EF05E0046AC5594562398B9160C7760@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from radish.scphys.kyoto-u.ac.jp ([130.54.54.131])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187nDo-00032N-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 17:37:08 -0800
Received: from tarte (srv01.scphys.kyoto-u.ac.jp [130.54.55.203])
	by radish.scphys.kyoto-u.ac.jp (8.9.3/3.7Wpl2-00022500) with SMTP id KAA20595
	for <nfs@lists.sourceforge.net>; Sat, 2 Nov 2002 10:28:17 +0900
To: <nfs@lists.sourceforge.net>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9160C7760@poexmb3.conoco.net>
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

> >
> > Yes, it appears so. But then, what is that "nohide" option
> about? I suspect
> > now that nohide is for _local_ filesystems.
> > So, how do people solve problems like mine?
> > Igor
> >
> 	nohide is a local option to make file systems mounted under things
> 	seeable, if the file system mounted under the local file systems is
> 	not compatible or because of where it exists in the kernel does not
> 	exist at the level of the NFS server  (a NFS client mount is not
> 	compatible or does not exist to the NFS server) it cannot be seen
> 	on the remote machine at all.
>
>
> 	Option 1: is don't setup the network in such a way that you need to
> 	reexport file systems to make things work.   Unless the machine
> 	that is reexporting is a firewall protecting something, you probably
> 	don't want to have a set of machine not accessable on your internal
> 	network that could or will need access to the internal
> network.  And
> 	if the machine is a firewall protecting things, I would suggest you
> 	carefully evaluate allowing the resource to be seen outside its
> 	protected area with a service such as NFS.
>
> 	Option 2: (again depends on exactly why you have the machine with
> 	the disk hidden from the other network), put the disks on
> the machine
> 	that is doing the reexporting and call it the disk server,
> or put two
> 	cards in the disk server so it is on both networks.
>
> 	Why is the disk machine in question not on the network that needs
> 	the data at least part of the time?   Is this a cluster
> with the standard
> 	(bad) head node setup?
>
> 	                                      Roger
>
>
"a NFS client mount ... does not exist to the NFS server" - This answers my
question. Nohide is no use for me.

We have an internal cluster and some outer machines we would want to use as
nodes in the cluster. It is possible because the head node is visible to the
both networks. Is this the "standard bad head node setup"? Then how do I
make it good?

Now the reason why I want to mount filesystems is that when we submit a task
to the cluster the working directory should be valid on all nodes, and had
better point to the same storage.

I can't put all the machines in one network. Neither can I take put all the
disks in the head node. I rather think about using samba or the Parallel
Virtual File System. Using samba in a Linux network seems weird, but it is
also the simplest after nfs.
Igor






-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
