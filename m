From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Soft vs Hard mounts
Date: Fri, 16 May 2003 00:49:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030516074909.GA11439@greglaptop.attbi.com>
References: <Pine.LNX.4.44.0305160902290.29488-100000@aristocat.lysator.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0305160902290.29488-100000@aristocat.lysator.liu.se>
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

On Fri, May 16, 2003 at 09:43:59AM +0200, Peter =C5strand wrote:

> Question: Why is this soft-vs-hard-mount debate so common in the Linux =
NFS=20
> world, but not in, for example, the Solaris community?=20
>=20
> My answer: Because Solaris has a better "umount -f" command. Linux user=
s
> want to use soft mounts to avoid rebooting in case of an unavailable
> server. Solaris users can use "umount -f" instead.

That's part of it. The rest of the mystery is:

1) Linux's nfs client code is not reliable at allowing SIGINT
to kill processes when disks mounted "hard,intr" go astray, and

2) Linux's nfs client code is not sufficiently careful about not
sucking unrelated processes into the black hole of a failed "hard"
mount.

I admit I've never done a systematic study of the Linux client for
these issues, but when you run into soft-mounting-advocates, they
generally talk about all 3 of these issues, not only umount.

On Solaris, it used to be the case that (2) required that you be
careful about exactly where you mounted things; I don't know about
now, but it was part of the lore of how to use the automounter + hard
mounts and not get burned.

-- greg



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
