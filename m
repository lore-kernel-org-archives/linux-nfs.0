Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:42423 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752507AbeDQPRT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 11:17:19 -0400
Content-Type: text/plain;
        charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20180417150002.GF10291@parsley.fieldses.org>
Date: Tue, 17 Apr 2018 11:17:03 -0400
CC: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>
Message-ID: <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <20180417150002.GF10291@parsley.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 17, 2018, at 11:00 AM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>=20
> On Mon, Apr 16, 2018 at 11:52:03PM -0700, Christoph Hellwig wrote:
>> Also even if we have a good reason to add it I absolutely want a =
config
>> option for the feature - it is a lot code adding potential attack
>> vectors, so we should not just enabled it by default.
>=20
> By the way, am I forgetting some mitigation or can a client provide =
any
> address it wants as the source server to copy from?
>=20
> That opens up the server to a lot of the same risks you'd see from
> unprivileged NFS mounts--a malicious client could copy from a server
> under it's control that's modified to exploit bugs in the server's NFS
> client code.

There is nothing in the specification that can protects from a malicious =
user to initiate a copy. There is GSSv3 that were added to prevent =
unprivileged server from accessing information from the source server =
without the user=E2=80=99s knowledge. I don=E2=80=99t see how copy =
offload is the same as unprivileged NFS mount. What copy offload feature =
offers is ability to READ a very specific file.=20

We do have in the pipe line GSSv3 implementation as well as the COPY =
piece that uses it. It was implemented by Andy and inherited by Anna. =
However, before we could submit that we need the copy offload to go in.

> I wonder if there's also the possibility of weird results even without
> malicious intent: e.g. a user copying files between two different
> servers may unintentionally tie up resources on the target server.

Is the target server in your case a target of the copy? The copy is =
initiated and will use resource of the copy source server and the copy =
destination server until either copy is done or client cancels the copy =
or client=E2=80=99s lease expires on the target copy server.=20

> There's interest in enabling unprivileged NFS mounts to allow
> unprivileged containers to do NFS mounts.  But even if we get to the
> point where we're comfortable enabling that, distributions may still
> want it off by default, and may advise admins to do firewalling that
> restricts the set of NFS servers that containers can mount.
>=20
> --b.

