From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: Announcing Release Two of NFSv4 on Linux 2.4
Date: Sun, 20 Jul 2003 18:23:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D06AB5@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Linux FS development (E-mail)" <fs-devel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
To: <nfs@sourceforge.net>
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

A new release of CITI U-M's NFSv4 on Linux 2.4 is
available.  For information on this release, see:

 https://linux24-nfsv4.citi.umich.edu/wiki


>From the Release Notes:

The NFSv4 implementation on Linux 2.4 is intended
for early adopters of NFSv4 who want to help beta
test commercial NFSv4-based products, or test the
Linux NFSv4 implementation. Our intention is to
provide a stable NFSv4 implementation on Linux with
these releases until a complete official Linux NFSv4
implementation appears in Linux 2.6. It is not
intended for use in production NFSv4 environments.
Think of this as beta quality software.

These releases provide an implementation of an NFSv4
client and server on a stable Linux kernel in an
easy-to-install set of packages. This allows more
intensive and broad-based testing of the Linux
NFSv4 implementation outside of developers' labs.

The NFSv4 implementation in all these releases
tracks the implementation contained in Linux 2.6
kernels as closely as possible. Our code base
should reflect the current state of the art (the
2.6 NFS implementation). We plan to be conservative
in including new 2.6 features, but aggressive in
including bug fixes, to make these releases stable
enough for testing under realistic workloads.


Main Features of Release Two

Release Two, like Release One, is not feature-complete.
Release Two supplements the features of Release One
with an NFSv4 server, support for ACLs and some support
for NFSv4 state in the client.  It also contains
support for RPCSEC-GSS Kerberos 5 integrity on the
client.

Features of Release Two include:

 *  NFS client for NFSv2, NFSv3, and NFSv4
 *  NFS server for NFSv2, NFSv3, and NFSv4 over
    UDP and TCP
 *  RPCSEC-GSS Kerberos 5 mutual authentication
    and integrity (client only)
 *  NFSv4 ACL support (client only)
 *  Initial support for NFSv4 state model (client
    only)
 *  Initial support for authentication against
    Windows 2000 Active Directory KDCs

        -- Chuck Lever
--
corporate: <cel at netapp dot com>
personal:  <chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
