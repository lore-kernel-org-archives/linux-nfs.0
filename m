From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: Announcing Release Two of NFSv4 on Linux 2.4
Date: Mon, 21 Jul 2003 08:27:02 -0700
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <482A3FA0050D21419C269D13989C6113D06AB9@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: <nfs@lists.sourceforge.net>,
	"Linux FS development (E-mail)" <linux-fsdevel@vger.kernel.org>
List-ID: <nfs.lists.sourceforge.net>

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
