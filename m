Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29202 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752069AbdIAN2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 09:28:32 -0400
Message-ID: <1504272509.10942.19.camel@redhat.com>
Subject: Re: [PATCH 0/7] Move nfs.conf to a shared library
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 01 Sep 2017 14:28:29 +0100
In-Reply-To: <bd61a590-6084-1daa-9dcc-471d6ab0f8ee@RedHat.com>
References: <1504093866.10850.1.camel@redhat.com>
         <20170830121522.GA16669@infradead.org>
         <4C0B11C8-941C-4323-99D2-A355F5841BAF@oracle.com>
         <bd61a590-6084-1daa-9dcc-471d6ab0f8ee@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-08-30 at 16:33 -0400, Steve Dickson wrote:
> 
> On 08/30/2017 10:20 AM, Chuck Lever wrote:
> > 
> > > On Aug 30, 2017, at 8:15 AM, Christoph Hellwig <hch@infradead.org
> > > > wrote:
> > > 
> > > On Wed, Aug 30, 2017 at 12:51:06PM +0100, Justin Mitchell wrote:
> > > > Moving the config parsing code out to a shared library fixes
> > > > both of these issues with minimal code changes. I appreciate
> > > > that the API this library presents is less than ideal, it was
> > > > left this way to reduce code changes at this point, and i
> > > > welcome suggestions for a sympathetic approach to improving it.
> > > 
> > > The general shard code approach look good, but is there any good
> > > reason not to merge libnfsidmap into nfs-utils and make it a
> > > static (or at least a private shared) library instead of
> > > introducing
> > > a new ABI?
> > 
> > Agreed: who else is using libnfsidmap? Is there currently a
> > packaging requirement that keeps it outside of nfs-utils?
> 
> I hope not... and I agree... lets use this effort to roll
> libnfsidmap into nfs-utils as static library.
> 
> The pain is more of a logistics issue for distro... IMHO...

afaics the three things that depend on libnfsidmap are nfs-ganesha,
freeipa-client, and sssd-nfs-idmap. the first two pull in nfs-utils
anyway, the latter would gain a few extra dependencies from pulling in
nfs-utils instead of just libnfsidmap.

Although that is somewhat academic as a merged tree could still be
packaged out as separate items, just as it is now, but internally can
share the code.

So I will look at doing that instead.

--
Justin Mitchell

