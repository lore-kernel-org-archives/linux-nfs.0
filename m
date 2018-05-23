Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:54000 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbeEWQFs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2018 12:05:48 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyEW=O20F3Ag7WKi8Uk21-Z-+g2QWO-93zsukAN8K4ErRw@mail.gmail.com>
Date: Wed, 23 May 2018 09:05:40 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <08BCD5D3-AB29-49BE-BA5F-FE0DE6FBC515@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com>
 <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
 <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
 <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
 <E54CA1D0-00E7-4EEF-B77F-78B65AF2FC08@oracle.com>
 <CAN-5tyH7gCyZ=-11TaYC3-WhYcB5n+W3Ua=TdDq=PZk24n+DbQ@mail.gmail.com>
 <EFDDE2C2-8E09-4F7A-B95A-785EA48E4804@oracle.com>
 <CAN-5tyGu++ULeUZKtZH=ZjUwqLNrcaZ4dSjH=iHXe0fCeudajA@mail.gmail.com>
 <58E2765B-6238-479D-968A-0FE2F5F01928@oracle.com>
 <CAN-5tyEW=O20F3Ag7WKi8Uk21-Z-+g2QWO-93zsukAN8K4ErRw@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Olga-

> On May 23, 2018, at 8:27 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Tue, May 22, 2018 at 6:36 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>> The question of whether the provided callback address is
>> valid is a different matter. "Is this user-provided
>> address one of my local interfaces or _ANY?" and then
>> either warn or fail the mount if not.
>=20
> clientaddr is advertised to the users for the callback information and
> yet the code uses it to construct the client id string.

To be clear, the only way the server knows about callback
information is because nfs4_proc_setclientid constructs a
cb_client4 argument to SETCLIENTID. The server treats
client ID strings as opaque blobs, used only for comparison
with other client ID strings. It does not matter that the
non-uniform client ID string we construct happens to have
random bogus crap in it, just as long as it is different
random bogus crap as any other client. ;-)

What matters is what goes in cb_client4.


> It should
> either not do so and acquire the IP information independently from
> what was supplied

The normal situation is that "clientaddr=3D" is not specified
by the administrator. Rather it is constructed by mount.nfs
and passed into the kernel with the other mount options.

(At least in the past) the kernel could not determine the
callback information by itself, which is why we have
clientaddr=3D in the first place.

I'm not sure from your original post why the admin was
supplying clientaddr=3D . I got the impression that it was
malicious, but maybe I am mistaken? Was there some problem
with the clientaddr=3D being supplied by mount.nfs ?


> or I think there should be a check on the user
> supplied input.

It's rare that an administrator would need to explicitly add
clientaddr=3D on the command line. But some input validation
is reasonable in the case where an admin (and not mount.nfs)
has specified this address.


> Would you support a patch that does the check and then (I'm making a
> choice here) fails the mount if the check fails.

I would need to know specifically what you have in mind for
"the check".


--
Chuck Lever



