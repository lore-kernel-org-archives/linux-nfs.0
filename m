Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35662 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753875AbdIYKbz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Sep 2017 06:31:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170925081452.GA17374@redhat.com>
Date: Mon, 25 Sep 2017 06:31:47 -0400
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Justin Mitchell <jumitche@redhat.com>
Message-Id: <A1915855-14CA-4CD1-B3F4-C1C2994ED83E@oracle.com>
References: <20170919164427.GV9536@redhat.com> <20170919172452.GB29104@fieldses.org> <20170921170017.GK32364@stefanha-x1.localdomain> <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com> <1506079954.4740.21.camel@redhat.com> <CAKOnarmwR=ZTrKD-L8j8979_kowK+gr4jniQ1mA-d7tXZTS61w@mail.gmail.com> <1506083199.4740.38.camel@redhat.com> <20170922152855.GD13709@stefanha-x1.localdomain> <20170922162320.GS12725@redhat.com> <AB9AE5F4-20EC-419D-838D-73BB42CEFCD6@oracle.com> <20170925081452.GA17374@redhat.com>
To: "Daniel P. Berrange" <berrange@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 25, 2017, at 4:14 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> 
> On Fri, Sep 22, 2017 at 02:31:56PM -0400, Chuck Lever wrote:
>> 
>>> On Sep 22, 2017, at 12:23 PM, Daniel P. Berrange <berrange@redhat.com> wrote:
>>> 
>>> In practice it
>>> probably doesn't matter, since I doubt VMWare would end up using
>>> NFS over AF_VSOCK, but conceptually I think AF_VSOCK makes more sense
>>> for a virt scenario.
>>> 
>>> Using AF_LOCAL would not be solving the hard problems for virt like
>>> migration either - it would just be hiding them under the carpet
>>> and pretending they don't exist. Again preferrable to actually use
>>> AF_VSOCK and define what the expected semantics are for migration.
>> 
>> There's no hiding or carpets. We're just reviewing the various
>> alternatives. AF_LOCAL has the same challenges as AF_VSOCK, as I've
>> said in the past, except that it already has well-defined semantics,
>> and it can be used in other environments besides host-guest.
> 
> The existing usage / other environments have no concept of migration, so
> there is no defined behaviour for AF_LOCAL wrt guest migration.

That is correct, and also true for all other current RPC
transports.


> So my point
> was that to use AF_LOCAL would be explicitly deciding to ignore the problem
> of migration.

That is nonsense, because all other current RPC transports also
do not support live guest migration, because that set of issues
has to do with NFS, not with RPC.

Further, AFAIK, the use of AF_LOCAL does not force any a priori
decision about whether live guest migration with NFS can be
supported. The question of live guest migration support is
orthogonal to the choice of RPC transport.


> Unless we define new semantics for AF_LOCAL wrt to migration,
> in the same way we'd have to define those semantics for AF_VSOCK.

Perhaps you misunderstood what I meant above by "already has
well-defined semantics". I simply meant that, unlike RPC on
AF_VSOCK currently, RPC on AF_LOCAL is well-defined and already
in use for some RPC programs. I am restating what Jeff Layton
already said in earlier e-mail. I was not making any claim about
whether live guest migration can be supported with NFS on an
AF_LOCAL transport.


--
Chuck Lever



