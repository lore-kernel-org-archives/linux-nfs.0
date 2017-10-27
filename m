Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:48271 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbdJ0N1O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 09:27:14 -0400
Received: by mail-io0-f173.google.com with SMTP id j17so12667424iod.5
        for <linux-nfs@vger.kernel.org>; Fri, 27 Oct 2017 06:27:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509110202.4704.7.camel@redhat.com>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
 <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com> <1509110202.4704.7.camel@redhat.com>
From: Matt Benjamin <mbenjami@redhat.com>
Date: Fri, 27 Oct 2017 09:27:13 -0400
Message-ID: <CAKOnarmotB2CXdiNvnYV1Jz+0JwwA8tgQjFN1Ssy5jN95T-rsw@mail.gmail.com>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
To: Jeff Layton <jlayton@redhat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Daniel Berrange <berrange@redhat.com>, NFSv4 <nfsv4@ietf.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

This doc says they are:
https://vmsplice.net/~stefan/stefanha-kvm-forum-2015.pdf

But only stream sockets are mentioned here:
https://wiki.qemu.org/Features/VirtioVsock

Trond and Chuck suggested in an offline conversation a few weeks ago
that they could imagine a datagram version of the transport being
useful.  It's probably worth passing that alone.

Matt

On Fri, Oct 27, 2017 at 9:16 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Thu, 2017-10-05 at 16:50 -0400, Matt Benjamin wrote:
>> Hi Stefan,
>>
>> On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>> > I have previously submitted patches that implement NFS client and nfsd
>> > support for the AF_VSOCK address family.  In order for this to be
>> > acceptable for merge the AF_VSOCK transport needs to be defined in an
>> > IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
>> >
>> > My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
>> > RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.
>> >
>>
>> I think "vsock" is the appropriate netid, not "tcpv."  Stream
>> orientation, if anything, is the general category containing TCP and
>> VSOCK, not the reverse.  But really I think it's just more clear.
>>
>
> Agreed. VSOCK is its own thing. It bears some resemblance to TCP, but
> calling it tcpv would be confusing. IIRC, Chuck only proposed that when
> we were discussing an alternative transport that would look more like a
> typical network.
>
> BTW: Does VSOCK have a connectionless mode, analogous to UDP? If so,
> then it may be nice to consider what the netid for that might look like
> as well, before we settle on any names.
> --
> Jeff Layton <jlayton@redhat.com>



-- 

Matt Benjamin
Red Hat, Inc.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://www.redhat.com/en/technologies/storage

tel.  734-821-5101
fax.  734-769-8938
cel.  734-216-5309
