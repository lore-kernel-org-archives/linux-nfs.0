Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:32826 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755978AbeDQQPP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 12:15:15 -0400
Received: by mail-vk0-f48.google.com with SMTP id q189so3218565vkb.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 09:15:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180417154106.GG10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com> <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org> <20180417065203.GA15145@infradead.org>
 <20180417150002.GF10291@parsley.fieldses.org> <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
 <20180417154106.GG10291@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 17 Apr 2018 12:15:13 -0400
Message-ID: <CAN-5tyHodwte-JUNjuqJBoyX26wFwrrmvkgc4kZrWDfN4FO_2Q@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 11:41 AM, J. Bruce Fields <bfields@redhat.com> wrot=
e:
> On Tue, Apr 17, 2018 at 11:17:03AM -0400, Olga Kornievskaia wrote:
>>
>>
>> > On Apr 17, 2018, at 11:00 AM, J. Bruce Fields <bfields@redhat.com>
>> > wrote:
>> >
>> > On Mon, Apr 16, 2018 at 11:52:03PM -0700, Christoph Hellwig wrote:
>> >> Also even if we have a good reason to add it I absolutely want a
>> >> config option for the feature - it is a lot code adding potential
>> >> attack vectors, so we should not just enabled it by default.
>> >
>> > By the way, am I forgetting some mitigation or can a client provide
>> > any address it wants as the source server to copy from?
>> >
>> > That opens up the server to a lot of the same risks you'd see from
>> > unprivileged NFS mounts--a malicious client could copy from a server
>> > under it's control that's modified to exploit bugs in the server's
>> > NFS client code.
>>
>> There is nothing in the specification that can protects from a
>> malicious user to initiate a copy. There is GSSv3 that were added to
>> prevent unprivileged server from accessing information from the source
>> server without the user=E2=80=99s knowledge. I don=E2=80=99t see how cop=
y offload is
>> the same as unprivileged NFS mount. What copy offload feature offers
>> is ability to READ a very specific file.
>
> I can't remember how much more protocol you need besides READ....  If
> you support 4.1+ as the copy protocol then you probably also need to do
> EXCHANGE_ID and CREATE_SESSION?  Fair enough, I agree that you're not
> exposing as much of the client code as an unprivileged mount would, but
> it's still a lot of opportunities for something to go wrong.

The spec has an option that I think in general is not very useful. We
did not implement in the "inter" series of patches. When the
COPY_NOTIFY is sent the client specifies destination server's IP
address(es). The source server could potentially then modify its
export policy to also allow access from those addresses.

The reason it's restrictive is even illustrated by the RFC itself. It
provides a possible scenario where source and destination servers have
a high-speed network that client isn't not aware of and it is not the
network the client connects to the destination server. Therefore
client can't provide the "real" IP address that the destination server
would utilize to do access the source server and read the file.

So I see your concern that in order to allow for the destination
server to read the file from the source server, the source server must
allow client_id/session creation and that actually really leads to
being able to send any other compound to the source server.

>> We do have in the pipe line GSSv3 implementation as well as the COPY
>> piece that uses it. It was implemented by Andy and inherited by Anna.
>> However, before we could submit that we need the copy offload to go
>> in.
>
> A malicious client can give the server credentials that a server under
> its control will accept.  GSSv3 lets the source server authenticate the
> read requests, but I don't think it helps here.

Btw, what your security thread here? If the client has control over
the server, then what are you trying to protect? If the client
controls the source server, then it can read whatever is stored on it
and if it decides to provide same ability to anybody else why would
that matter? How's any different from giving away your password to
whomever and them accessing files as that user?

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
