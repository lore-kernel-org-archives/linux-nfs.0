Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:37570 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751582AbeEVQR6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 12:17:58 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: EVM HMAC and FS UUID
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180522160751.GB30724@fieldses.org>
Date: Tue, 22 May 2018 09:17:53 -0700
Cc: trond.myklebust@hammerspace.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0AD3BFFF-8A3D-440A-B186-0019B8D924B2@oracle.com>
References: <04B6BFF9-AC1E-4E46-810B-7DDE5ED63345@oracle.com>
 <20180522160751.GB30724@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 22, 2018, at 9:07 AM, Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, May 22, 2018 at 08:53:34AM -0700, Chuck Lever wrote:
>> Hi-
>> 
>> I'm continuing to look at NFS support for the Linux Integrity
>> Measurement Architecture.
>> 
>> When computing an HMAC hash of file attributes, sometimes the
>> FS UUID is included. For a client to verify that hash, the
>> server will have to expose that UUID somehow.
>> 
>> Is there currently an NFSv4 attribute that carries the FS UUID?
> 
> I think the fsid is as close as you get.
> 
> Do you need to calculate hashes in exactly the way the server does?  If
> you're assuming a "dumb server" that just stores signatures without
> interpreting them, then maybe not?

The hashes have to be computed the same way everywhere, of course,
whether it's on a client or on the server.

Assuming that NFS were not in the picture, then the EVM hash would
use the raw FS UUID. This is the hash that would be exposed to NFS
clients if that filesystem were suddenly to be exported. So the
NFS clients would need to have the same raw FS UUID in order to
verify the hash. (And I'm actually not sure what benefit there is
to including the FS UUID).

I see two alternatives:

-- Provide a new read-only filesystem attribute that exposes the
   FS UUID

-- The FS UUID is optional. We could make it illegal to use the
   FS UUID in EVM hashes that will be exposed via NFS

The bigger picture:

- The input set for the hash contains optional items that will have
to be given to remote EVM hash consumers. I think a new attribute
that lists the set of hashed attributes will be necessary.

- The input set can contain security.* xattrs, like security.SMACK64.
These are currently not exposed to NFS clients, but not all files
will have them. Not quite sure how to make that work generally.


--
Chuck Lever



