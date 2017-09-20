Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38357 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdITOkx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Sep 2017 10:40:53 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170920131641.GC14329@fieldses.org>
Date: Wed, 20 Sep 2017 10:40:45 -0400
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Message-Id: <E8E404FD-420A-45C6-B46B-F1E2A4133F17@oracle.com>
References: <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com> <20170918180927.GD12759@stefanha-x1.localdomain> <20170919093140.GF9536@redhat.com> <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com> <20170919151051.GS9536@redhat.com> <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com> <20170919164427.GV9536@redhat.com> <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com> <20170919204224.GA14329@fieldses.org> <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com> <20170920131641.GC14329@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 20, 2017, at 9:16 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Sep 19, 2017 at 05:09:25PM -0400, Chuck Lever wrote:
>> 
>>> On Sep 19, 2017, at 4:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Tue, Sep 19, 2017 at 03:56:50PM -0400, Chuck Lever wrote:
>>>> A proof of concept is nice, but it isn't sufficient for merging
>>>> NFS/VSOCK into upstream Linux. Unlike Ceph, NFS is an Internet
>>>> standard. We can't introduce changes as we please and expect
>>>> the rest of the world to follow us.
>>>> 
>>>> I know the Ganesha folks chafe at this requirement, because
>>>> standardization progress can sometimes be measured in geological
>>>> time units.
>>> 
>>> It doesn't need to be--I think we're only asking for a few pages here,
>>> and nothing especially complicated (at the protocol level).
>> 
>> That would define RPC over VSOCK. I would like to see a problem
>> statement here, and we'd want to find a normative reference defining
>> VSOCK addressing. Does one exist?
>> 
>> My sense is that NFS on VSOCK would need more. The proof of concept
>> I'm aware of drops a lot of functionality (for example, NFSv2/3 is
>> excluded, and so is RPCSEC GSS and NFSv4.0 backchannel) to make NFS
>> work on this transport. Interoperability would require that list
>> be written somewhere.
> 
> I don't think they need to support NFSv2/3 or RPCSEC_GSS, but it could
> be worth a little text to explain why not, if they don't.

Right, I'm not taking a position on whether or not those things
should be supported. But the list of features that don't work on
VSOCK mounts is substantial and needs to be documented, IMO.


>> We also need to deal with filehandles and lock state during guest
>> live migration.
> 
> That sounds like a separate issue independent of transport.

Yes, it is separate from transport specifics, but it's significant.


> I've been assuming there's still some use to them in an implementation
> that doesn't support migration at first.

File handles suddenly change and lock state vanishes after a live
migration event, both of which would be catastrophic for hypervisor
mount points. This might be mitigated with some NFS protocol
changes, but some implementation work is definitely required. This
work hasn't been scoped, as far as I am aware.
