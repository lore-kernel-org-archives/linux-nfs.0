From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@lysator.liu.se>
Subject: Soft vs Hard mounts
Date: Fri, 16 May 2003 09:43:59 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0305160902290.29488-100000@aristocat.lysator.liu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
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


> if using hardmounts, everybody sits and wait for the other server
> to come back online... if and when it does, and if it comes up
> at some other ip# or some other nfs ports, other pcs need to be
> rebooted too
>         - i dont like waiting around or rebooting

Question: Why is this soft-vs-hard-mount debate so common in the Linux NF=
S=20
world, but not in, for example, the Solaris community?=20

My answer: Because Solaris has a better "umount -f" command. Linux users
want to use soft mounts to avoid rebooting in case of an unavailable
server. Solaris users can use "umount -f" instead.

In case you don't know what Solaris umount -f does, here's the man page=20
info:

     -f    Forcibly unmount a file system.

           Without this option, umount does not allow a file sys-
           tem  to  be  unmounted if a file on the file system is
           busy. Using this option can cause data loss  for  open
           files; programs which access files after the file sys-
           tem has been unmounted will get an error (EIO).

umount -f is much better than soft mounts: Even though it can lead to dat=
a=20
loss/corruption, you have to invoke this command manually. Data=20
loss/corruption won't occur behind your back, whenever a timeout occurs.=20

It would be really nice with this kind of "umount -f" in Linux.=20

--=20
/Peter =C5strand <astrand@lysator.liu.se>





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
