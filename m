Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f173.google.com ([209.85.128.173]:57085 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab3IFQsq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Sep 2013 12:48:46 -0400
Received: by mail-ve0-f173.google.com with SMTP id cz12so1815601veb.32
        for <linux-nfs@vger.kernel.org>; Fri, 06 Sep 2013 09:48:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130906093636.6818e7b2@corrin.poochiereds.net>
References: <20130905162110.GA17920@gmail.com>
	<20130905170303.GB17330@us.ibm.com>
	<20130905191139.GA20830@gmail.com>
	<1378411320.5450.27.camel@leira.trondhjem.org>
	<20130905213649.GA21944@gmail.com>
	<1378418243.5450.29.camel@leira.trondhjem.org>
	<20130905223420.GA23192@gmail.com>
	<20130906093636.6818e7b2@corrin.poochiereds.net>
Date: Fri, 6 Sep 2013 11:48:45 -0500
Message-ID: <CAKjHkpBW+LWKuKuHnUfKNxwDZeX3SOFKv_jYeNGF8ezdAnKnvg@mail.gmail.com>
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
From: Quentin Barnes <qbarnes@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff, can your try out my test program in the base note on your
RHEL5.9 or later RHEL5.x kernels?

I reverified that running the test on a 2.6.18-348.16.1.el5 x86_64
kernel (latest released RHEL5.9) does not show the problem for me.
Based on what you and Trond have said in this thread though, I'm
really curious why it doesn't have the problem.

On Fri, Sep 6, 2013 at 8:36 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Thu, 5 Sep 2013 17:34:20 -0500
> Quentin Barnes <qbarnes@gmail.com> wrote:
>
>> On Thu, Sep 05, 2013 at 09:57:24PM +0000, Myklebust, Trond wrote:
>> > On Thu, 2013-09-05 at 16:36 -0500, Quentin Barnes wrote:
>> > > On Thu, Sep 05, 2013 at 08:02:01PM +0000, Myklebust, Trond wrote:
>> > > > On Thu, 2013-09-05 at 14:11 -0500, Quentin Barnes wrote:
>> > > > > On Thu, Sep 05, 2013 at 12:03:03PM -0500, Malahal Naineni wrote:
>> > > > > > Neil Brown posted a patch couple days ago for this!
>> > > > > >
>> > > > > > http://thread.gmane.org/gmane.linux.nfs/58473
>> > > > >
>> > > > > I tried Neil's patch on a v3.11 kernel.  The rebuilt kernel still
>> > > > > exhibited the same 1000s of WRITEs/sec problem.
>> > > > >
>> > > > > Any other ideas?
>> > > >
>> > > > Yes. Please try the attached patch.
>> > >
>> > > Great!  That did the trick!
>> > >
>> > > Do you feel this patch could be worthy of pushing it upstream in its
>> > > current state or was it just to verify a theory?
>> > >
>> > >
>> > > In comparing the nfs_flush_incompatible() implementations between
>> > > RHEL5 and v3.11 (without your patch), the guts of the algorithm seem
>> > > more or less logically equivalent to me on whether or not to flush
>> > > the page.  Also, when and where nfs_flush_incompatible() is invoked
>> > > seems the same.  Would you provide a very brief pointer to clue me
>> > > in as to why this problem didn't also manifest circa 2.6.18 days?
>> >
>> > There was no nfs_vm_page_mkwrite() to handle page faults in the 2.6.18
>> > days, and so the risk was that your mmapped writes could end up being
>> > sent with the wrong credentials.
>>
>> Ah!  You're right that nfs_vm_page_mkwrite() was missing from
>> the original 2.6.18, so that makes sense, however, Red Hat had
>> backported that function starting with their RHEL5.9(*) kernels,
>> yet the problem doesn't manifest on RHEL5.9.  Maybe the answer lies
>> somewhere in RHEL5.9's do_wp_page(), or up that call path, but
>> glancing through it, it all looks pretty close though.
>>
>>
>> (*) That was the source I using when comparing with the 3.11 source
>> when studying your patch since it was the last kernel known to me
>> without the problem.
>>
>
> I'm pretty sure RHEL5 has a similar problem, but it's unclear to me why
> you're not seeing it there. I have a RHBZ open vs. RHEL5 but it's marked
> private at the moment (I'll see about opening it up). I brought this up
> upstream about a year ago with this strawman patch:
>
>     http://article.gmane.org/gmane.linux.nfs/51240
>
> ...at the time Trond said he was working on a set of patches to track
> the open/lock stateid on a per-req basis. Did that approach not pan
> out?
>
> Also, do you need to do a similar fix to nfs_can_coalesce_requests?
>
> Thanks,
> --
> Jeff Layton <jlayton@redhat.com>
