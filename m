From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Soft vs Hard mounts
Date: Fri, 16 May 2003 09:13:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61131274DD@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Greg Lindahl" <lindahl@keyresearch.com>
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

hi greg-

very succinct, and i think this is the crux of the problem.

recently trond mentioned that this issue was not likely to
be addressed until after 2.6 because it requires architectural
changes in the VFS layer and probably a new type of semaphor
implementation.

in the meantime, i think we can address some of the instability:

1.  reduce or eliminate the ESTALE errors that occur after
    a server reboot.  this is probably some kind of client
    bug.

2.  get lazy unmounting (umount -l) to work for NFS.  i tried
    this recently, and it didn't work as advertised.

3.  make soft mounts work more reliably by purging a file's
    page cache contents when a soft timeout occurs

4.  educate sysadmins how to make soft mounts more reliable
    by thoroughly testing to determine a reasonable set of
    mount options.

> On Fri, May 16, 2003 at 09:43:59AM +0200, Peter =C5strand wrote:
>=20
> > Question: Why is this soft-vs-hard-mount debate so common=20
> in the Linux NFS=20
> > world, but not in, for example, the Solaris community?=20
> >=20
> > My answer: Because Solaris has a better "umount -f"=20
> command. Linux users
> > want to use soft mounts to avoid rebooting in case of an unavailable
> > server. Solaris users can use "umount -f" instead.
>=20
> That's part of it. The rest of the mystery is:
>=20
> 1) Linux's nfs client code is not reliable at allowing SIGINT
> to kill processes when disks mounted "hard,intr" go astray, and
>=20
> 2) Linux's nfs client code is not sufficiently careful about not
> sucking unrelated processes into the black hole of a failed "hard"
> mount.
>=20
> I admit I've never done a systematic study of the Linux client for
> these issues, but when you run into soft-mounting-advocates, they
> generally talk about all 3 of these issues, not only umount.
>=20
> On Solaris, it used to be the case that (2) required that you be
> careful about exactly where you mounted things; I don't know about
> now, but it was part of the lore of how to use the automounter + hard
> mounts and not get burned.
>=20
> -- greg
>=20
>=20
>=20
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux=20
> enterprise solutions
> www.enterpriselinuxforum.com
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
