Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33690 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdJ0SGL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 14:06:11 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1509127168.4946.14.camel@redhat.com>
Date: Fri, 27 Oct 2017 14:06:00 -0400
Cc: Matt Benjamin <mbenjami@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Daniel Berrange <berrange@redhat.com>, NFSv4 <nfsv4@ietf.org>
Message-Id: <E3C7DEB1-7859-4490-A2DE-475458A2ECA0@oracle.com>
References: <20171005200835.GA31525@stefanha-x1.localdomain> <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com> <1509110202.4704.7.camel@redhat.com> <CAKOnarmotB2CXdiNvnYV1Jz+0JwwA8tgQjFN1Ssy5jN95T-rsw@mail.gmail.com> <1509127168.4946.14.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 27, 2017, at 1:59 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> I agree -- that could be useful later. Given that, maybe we should call
> the netids something like:
> 
>    vsockc: connected vsock
>    vsockd: datagram vsock
> 
> AIUI, netids are just something we inherited from Sun when we got the
> TI-RPC library. I don't think they are governed by any sort of
> names+numbers authority, are they?

Jeff, the relevant authority is IANA, and that's the whole
point of this I-D: to request netid assignments and specify
the universal address format for the VSOCK AF.


> If not then we're probably define it to whatever we wish, though it
> might be a good idea to talk to the Solaris folks and see if they have
> any input as to the naming.
> 
> -- Jeff
> 
> On Fri, 2017-10-27 at 09:27 -0400, Matt Benjamin wrote:
>> Hi Jeff,
>> 
>> This doc says they are:
>> https://vmsplice.net/~stefan/stefanha-kvm-forum-2015.pdf
>> 
>> But only stream sockets are mentioned here:
>> https://wiki.qemu.org/Features/VirtioVsock
>> 
>> Trond and Chuck suggested in an offline conversation a few weeks ago
>> that they could imagine a datagram version of the transport being
>> useful.  It's probably worth passing that alone.
>> 
>> Matt
>> 
>> On Fri, Oct 27, 2017 at 9:16 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>> On Thu, 2017-10-05 at 16:50 -0400, Matt Benjamin wrote:
>>>> Hi Stefan,
>>>> 
>>>> On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>>>>> I have previously submitted patches that implement NFS client and nfsd
>>>>> support for the AF_VSOCK address family.  In order for this to be
>>>>> acceptable for merge the AF_VSOCK transport needs to be defined in an
>>>>> IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
>>>>> 
>>>>> My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
>>>>> RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.
>>>>> 
>>>> 
>>>> I think "vsock" is the appropriate netid, not "tcpv."  Stream
>>>> orientation, if anything, is the general category containing TCP and
>>>> VSOCK, not the reverse.  But really I think it's just more clear.
>>>> 
>>> 
>>> Agreed. VSOCK is its own thing. It bears some resemblance to TCP, but
>>> calling it tcpv would be confusing. IIRC, Chuck only proposed that when
>>> we were discussing an alternative transport that would look more like a
>>> typical network.
>>> 
>>> BTW: Does VSOCK have a connectionless mode, analogous to UDP? If so,
>>> then it may be nice to consider what the netid for that might look like
>>> as well, before we settle on any names.
>>> --
>>> Jeff Layton <jlayton@redhat.com>
>> 
>> 
>> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>

--
Chuck Lever



