Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17950 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751828AbdITO7f (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Sep 2017 10:59:35 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170920144557.GD14329@fieldses.org>
Date: Wed, 20 Sep 2017 10:59:24 -0400
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Message-Id: <202BF722-77BC-4EF2-BD75-9AA42CBF4A94@oracle.com>
References: <20170919093140.GF9536@redhat.com> <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com> <20170919151051.GS9536@redhat.com> <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com> <20170919164427.GV9536@redhat.com> <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com> <20170919204224.GA14329@fieldses.org> <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com> <20170920131641.GC14329@fieldses.org> <E8E404FD-420A-45C6-B46B-F1E2A4133F17@oracle.com> <20170920144557.GD14329@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 20, 2017, at 10:45 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Wed, Sep 20, 2017 at 10:40:45AM -0400, Chuck Lever wrote:
>> File handles suddenly change and lock state vanishes after a live
>> migration event, both of which would be catastrophic for hypervisor
>> mount points.
> 
> They're talking about a Ganesha/Ceph backend.  It should be able to
> preserve filehandles.

That's only one possible implementation. I'm thinking in terms of
what needs to be documented for interoperability purposes.


> Lock migration will require server-side implementation work but not
> protocol changes that I'm aware of.
> 
> It could be a lot of implementation work, though.

Agreed.


--
Chuck Lever



