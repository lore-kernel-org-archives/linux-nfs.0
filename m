Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:44404 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754658AbeEWSUW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2018 14:20:22 -0400
Received: by mail-vk0-f49.google.com with SMTP id x66-v6so13725585vka.11
        for <linux-nfs@vger.kernel.org>; Wed, 23 May 2018 11:20:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <08BCD5D3-AB29-49BE-BA5F-FE0DE6FBC515@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com> <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
 <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com> <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
 <E54CA1D0-00E7-4EEF-B77F-78B65AF2FC08@oracle.com> <CAN-5tyH7gCyZ=-11TaYC3-WhYcB5n+W3Ua=TdDq=PZk24n+DbQ@mail.gmail.com>
 <EFDDE2C2-8E09-4F7A-B95A-785EA48E4804@oracle.com> <CAN-5tyGu++ULeUZKtZH=ZjUwqLNrcaZ4dSjH=iHXe0fCeudajA@mail.gmail.com>
 <58E2765B-6238-479D-968A-0FE2F5F01928@oracle.com> <CAN-5tyEW=O20F3Ag7WKi8Uk21-Z-+g2QWO-93zsukAN8K4ErRw@mail.gmail.com>
 <08BCD5D3-AB29-49BE-BA5F-FE0DE6FBC515@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 23 May 2018 14:20:20 -0400
Message-ID: <CAN-5tyE-n8bkJJy8vU6eVn+qjQ1Wh4ZZq_Do0R51wMuLw3e9RA@mail.gmail.com>
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 23, 2018 at 12:05 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hey Olga-
>
>> On May 23, 2018, at 8:27 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Tue, May 22, 2018 at 6:36 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> The question of whether the provided callback address is
>>> valid is a different matter. "Is this user-provided
>>> address one of my local interfaces or _ANY?" and then
>>> either warn or fail the mount if not.
>>
>> clientaddr is advertised to the users for the callback information and
>> yet the code uses it to construct the client id string.
>
> To be clear, the only way the server knows about callback
> information is because nfs4_proc_setclientid constructs a
> cb_client4 argument to SETCLIENTID. The server treats
> client ID strings as opaque blobs, used only for comparison
> with other client ID strings. It does not matter that the
> non-uniform client ID string we construct happens to have
> random bogus crap in it, just as long as it is different
> random bogus crap as any other client. ;-)
>
> What matters is what goes in cb_client4.
>
>
>> It should
>> either not do so and acquire the IP information independently from
>> what was supplied
>
> The normal situation is that "clientaddr=" is not specified
> by the administrator. Rather it is constructed by mount.nfs
> and passed into the kernel with the other mount options.
>
> (At least in the past) the kernel could not determine the
> callback information by itself, which is why we have
> clientaddr= in the first place.
>
> I'm not sure from your original post why the admin was
> supplying clientaddr= . I got the impression that it was
> malicious, but maybe I am mistaken?

In practice it was a simple misconfiguration on the part of the admin
that input an incorrect address. Mistaken or malicious attempt will
greatly interfere with a legitimate user.

> Was there some problem
> with the clientaddr= being supplied by mount.nfs ?

The problem is that clientaddr is allowed to be specified by the user
and have no checks before being used as an input to the client id
content.

>> or I think there should be a check on the user
>> supplied input.
>
> It's rare that an administrator would need to explicitly add
> clientaddr= on the command line.

I guess not rare enough as it came up as a customer case.

>  But some input validation
> is reasonable in the case where an admin (and not mount.nfs)
> has specified this address.

I believe so and that's what I'm trying to accomplish.

>> Would you support a patch that does the check and then (I'm making a
>> choice here) fails the mount if the check fails.
>
> I would need to know specifically what you have in mind for
> "the check".

I will make another attempt at the check to include allowing for the
0.0.0.0 and whatever equivalent of it is in ipv6.
