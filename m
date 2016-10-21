Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35532 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932614AbcJUNEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 09:04:11 -0400
Date: Fri, 21 Oct 2016 14:04:08 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 01/10] SUNRPC: add AF_VSOCK support to addr.[ch]
Message-ID: <20161021130408.GG4648@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
 <1475834514-4058-2-git-send-email-stefanha@redhat.com>
 <E1AFFD7C-D0D3-495E-BB11-94358FF31DBA@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Fnm8lRGFTVS/3GuM"
In-Reply-To: <E1AFFD7C-D0D3-495E-BB11-94358FF31DBA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Fnm8lRGFTVS/3GuM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 07, 2016 at 11:15:20AM -0400, Chuck Lever wrote:
> > On Oct 7, 2016, at 6:01 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> >=20
> > AF_VSOCK addresses are a Context ID (CID) and port number tuple.  The
> > CID is a unique address, similar to a IP address on a local subnet.
> >=20
> > Extend the addr.h functions to handle AF_VSOCK addresses.

Thanks for your reply.  A lot of these areas are covered in the
presentation I gave at Connectathon 2016.  Here is the link in case
you're interested:
http://vmsplice.net/~stefan/stefanha-connectathon-2016.pdf

Replies to your questions below:

> I'm wondering if there's a specification for how to construct
> the universal address form of an AF_VSOCK address. This would
> be needed for populating an fs_locations response, or for
> updating the NFS server's local rpcbind service.

The uaddr format I'm proposing is "vsock:cid.port".  Both cid and port
are unsigned 32-bit integers.  The netid I'm proposing is "vsock".

> A traditional NFS server employs IP-address based access
> control. How does that work with the new address family? Do
> you expect changes to mountd or exportfs?

Yes, the /etc/exports syntax I'm proposing is:

  /srv/vm001 vsock:5(rw)

This allows CID 5 to access /srv/vm001.  The CID is equivalent to an IP
address.

This patch series only addresses the NFS client side but I will be
sending nfsd and nfs-utils rpc.mountd patches once I've completed the
work.

The way it works so far is that /proc/net/rpc/auth.unix.ip is extended
to support not just IP but also vsock addresses.  So the cache is
separated by network address family (IP or vsock).

> Is there a standard that defines the "vsock" netid? A new
> netid requires at least an IANA action. Is there a document
> that describes how RPC works with a VSOCK transport?

I haven't submitted a request to IANA yet.  The RPC is the same as TCP
(it uses the same Recording Marking to delimit boundaries in the
stream).

> This work appears to define two separate things: a new address
> family, and a new transport type. Wouldn't it be cleaner to
> dispense with the "proto=3Dvsock" piece, and just support TCP
> over AF_VSOCK (just as it works for AF_INET and AF_INET6) ?

Can you explain how this would simplify things?  I don't think much of
the code is transport-specific (the stream parsing is already shared
with TCP).  Most of the code is to add the new address family.  AF_VSOCK
already offers TCP-like semantics natively so no extra protocol is used
on top.

> At Connectathon, we discussed what happens when a guest is
> live-migrated to another host with a vsock-enabled NFSD.
> Essentially, the server at the known-local address would
> change identities and its content could be completely
> different. For instance, the file handles would all change,
> including the file handle of the export's root directory.
> Clients don't tolerate that especially well.

This issue remains.  I looked into checkpoint-resume style TCP_REPAIR to
allow existing connections to persist across migration but I hope a
simpler approach can be taken.

Let's forget about AF_VSOCK, the problem is that an NFS client loses
connectivity to the old server and must connect to the new server.  We
want to keep all state (open files, etc).  Are configurations like that
possible with Linux nfsd?

> Can't a Docker-based or kvm-based guest simply mount one of
> the host's local file systems directly? What would be the
> value of inserting NFS into that picture?

The host cannot access a file system currently mounted by the guest and
vice versa.  NFS allows sharing of a file system between the host and
one or more guests.

--Fnm8lRGFTVS/3GuM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYChJIAAoJEJykq7OBq3PIL8sIALmo+5A47pe147u6UG6W5yHc
98UVaDadUJuKC/4wQAFN4gkLDDnrrdh6RaLm+iN3hwVx6Nwf24rkesL7pXBc1916
rTKYMhkxVGezuj1kWNqwiYhuG18Kqv5LHpuGP9ECALsZaxnI+XI5n4O6McHZhcFP
oxlGUxnTgFCNywZYzxAlRqnkOoUDELhx/9Wcl3QYCR5VAazNuyaxPLR4owQ8spZt
h0Gq8nLAYMXpN6RixgnRnZp3SB6dF8V7Bl9gVuGADL0JmIF16CWJXIP971nJvspq
TSfQQ1abBGtNeUGRo4M9WeH4t3JOGWYd4Vqvzg+wkq4adnsMcjmYfiHWmyOGi+U=
=rgGE
-----END PGP SIGNATURE-----

--Fnm8lRGFTVS/3GuM--
