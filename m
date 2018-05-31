Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:42564 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755729AbeEaRJj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 13:09:39 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Enabling EVM on NFS mounts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <729C6BCE-D60D-4687-8DD0-52E1EF35E535@oracle.com>
Date: Thu, 31 May 2018 13:09:35 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B2F3310F-541B-4A07-9142-C66424DD5EAF@oracle.com>
References: <729C6BCE-D60D-4687-8DD0-52E1EF35E535@oracle.com>
To: linux-integrity@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 21, 2018, at 6:28 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
> I'm in the middle of rewriting
>=20
> =
https://datatracker.ietf.org/doc/draft-cel-nfsv4-linux-seclabel-xtensions/=

>=20
> which was recently rejected by the nfsv4 Working Group for
> plausible and fixable reasons. They like the idea, but my
> proposal for using NFSv4 security labels is not workable
> even as an experiment.
>=20
> As I compose a fresh Internet-Draft I'm trying to understand
> what an EVM HMAC covers, and I found this:
>=20
> http://linux-ima.sourceforge.net/evmctl.1.html
>=20
>> EVM protects file metadata by including following attributes into =
HMAC and signature calculation: inode number, inode generation, UID, =
GID, file mode, security.selinux, security.SMACK64, security.ima, =
security.capability.
>=20
>> EVM HMAC and signature may also include additional file and file =
system attributes. Currently supported additional attributes are =
filesystem UUID and extra SMACK extended attributes.
>=20
>=20
> The computation of the IMA HMAC is straightforward, but it
> appears that the EVM HMAC is evolving, and not all of the
> input items would necessarily be visible to remote EVM
> consumers.
>=20
> Is there any way an NFS client would be able to tell exactly
> what attributes were used to compute an EVM hash, and what
> should it do if the whole input set is not available for
> verification?
>=20
> Amongst the security. xattrs, I believe only security.selinux
> is currently exposed via NFS. Thus an NFS client EVM would
> see only that particular xattr and not others by which it can
> compute or verify the EVM hash.
>=20
> Does the inclusion here of "security.capability" mean that NFS
> support for EVM and for file capabilities are inseparable? Is
> the content of security.capability in a binary or human-readable
> format?
>=20
> Filesystem attributes such as a UUID, type, or disk label might
> not be visible to NFS clients.
>=20
> Would there be any reason to protect ACLs with the EVM hash?

I've submitted a replacement document for=20

=
https://datatracker.ietf.org/doc/draft-cel-nfsv4-linux-seclabel-xtensions/=


Please see:

https://datatracker.ietf.org/doc/draft-ietf-nfsv4-integrity-measurement/

The following changes have been made since linux-seclabel-xtensions:

- The original personal draft has been promoted to a Working Group
document. There were no objections from members of the WG to
taking this work. The WG will meet at IETF 102 in July and I
intend to discuss this work with them at that time.

- Support for Linux file capabilities has been removed. I plan to
submit a separate Internet-Draft that specifies capabilities
support, once nfsv4-integrity-measurement is under way.

- The use of NFSv4 Security Labels has been replaced with new
OPTIONAL fattr4 attributes. The document includes an XDR definition
of the new attributes. The document is now organized like RFC 8275.

- To address the issues I raised earlier in this thread, support has
been added for EVM HMAC hashes covering optional extended attributes.
The server advertises a per-filesystem list of which optional
attributes are included in EVM HMAC hashes.

- The discussion is more sensitive to servers that support storing
hashes but do not permit native access to them (ie., non-Linux
NFSv4.2 server implementations).

- The Security Considerations section has been expanded.


--
Chuck Lever



