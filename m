Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab3IINES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Sep 2013 09:04:18 -0400
Date: Mon, 9 Sep 2013 09:04:24 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Quentin Barnes <qbarnes@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
Message-ID: <20130909090424.1a780b49@tlielax.poochiereds.net>
In-Reply-To: <CAKjHkpBW+LWKuKuHnUfKNxwDZeX3SOFKv_jYeNGF8ezdAnKnvg@mail.gmail.com>
References: <20130905162110.GA17920@gmail.com>
 <20130905170303.GB17330@us.ibm.com>
 <20130905191139.GA20830@gmail.com>
 <1378411320.5450.27.camel@leira.trondhjem.org>
 <20130905213649.GA21944@gmail.com>
 <1378418243.5450.29.camel@leira.trondhjem.org>
 <20130905223420.GA23192@gmail.com>
 <20130906093636.6818e7b2@corrin.poochiereds.net>
 <CAKjHkpBW+LWKuKuHnUfKNxwDZeX3SOFKv_jYeNGF8ezdAnKnvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 6 Sep 2013 11:48:45 -0500
Quentin Barnes <qbarnes@gmail.com> wrote:

> Jeff, can your try out my test program in the base note on your
> RHEL5.9 or later RHEL5.x kernels?
> 
> I reverified that running the test on a 2.6.18-348.16.1.el5 x86_64
> kernel (latest released RHEL5.9) does not show the problem for me.
> Based on what you and Trond have said in this thread though, I'm
> really curious why it doesn't have the problem.
> 

I can confirm what you see on RHEL5. One difference is that RHEL5's
page_mkwrite handler does not do wait_on_page_writeback. That was added
as part of the stable pages work that went in a while back, so that may 
be the main difference. Adding that in doesn't seem to materially
change things though.

In any case, what I see is that the initial program just ends up with a
two calls to nfs_vm_page_mkwrite(). They both push out a WRITE and then
things settle down (likely because the page is still marked dirty).

Eventually, another write occurs and the dirty page gets pushed out to
the server in a small flurry of WRITEs to the same range.Then, things
settle down again until there's another small flurry of activity.

My suspicion is that there is a race condition involved here, but I'm
unclear on where it is. I'm not 100% convinced this is a bug, but page
fault semantics aren't my strong suit.

You may want to consider opening a "formal" RH support case if you have
interest in getting Trond's patch backported, and/or following up on
why RHEL5 behaves the way it does.


> On Fri, Sep 6, 2013 at 8:36 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Thu, 5 Sep 2013 17:34:20 -0500
> > Quentin Barnes <qbarnes@gmail.com> wrote:
> >
> >> On Thu, Sep 05, 2013 at 09:57:24PM +0000, Myklebust, Trond wrote:
> >> > On Thu, 2013-09-05 at 16:36 -0500, Quentin Barnes wrote:
> >> > > On Thu, Sep 05, 2013 at 08:02:01PM +0000, Myklebust, Trond wrote:
> >> > > > On Thu, 2013-09-05 at 14:11 -0500, Quentin Barnes wrote:
> >> > > > > On Thu, Sep 05, 2013 at 12:03:03PM -0500, Malahal Naineni wrote:
> >> > > > > > Neil Brown posted a patch couple days ago for this!
> >> > > > > >
> >> > > > > > http://thread.gmane.org/gmane.linux.nfs/58473
> >> > > > >
> >> > > > > I tried Neil's patch on a v3.11 kernel.  The rebuilt kernel still
> >> > > > > exhibited the same 1000s of WRITEs/sec problem.
> >> > > > >
> >> > > > > Any other ideas?
> >> > > >
> >> > > > Yes. Please try the attached patch.
> >> > >
> >> > > Great!  That did the trick!
> >> > >
> >> > > Do you feel this patch could be worthy of pushing it upstream in its
> >> > > current state or was it just to verify a theory?
> >> > >
> >> > >
> >> > > In comparing the nfs_flush_incompatible() implementations between
> >> > > RHEL5 and v3.11 (without your patch), the guts of the algorithm seem
> >> > > more or less logically equivalent to me on whether or not to flush
> >> > > the page.  Also, when and where nfs_flush_incompatible() is invoked
> >> > > seems the same.  Would you provide a very brief pointer to clue me
> >> > > in as to why this problem didn't also manifest circa 2.6.18 days?
> >> >
> >> > There was no nfs_vm_page_mkwrite() to handle page faults in the 2.6.18
> >> > days, and so the risk was that your mmapped writes could end up being
> >> > sent with the wrong credentials.
> >>
> >> Ah!  You're right that nfs_vm_page_mkwrite() was missing from
> >> the original 2.6.18, so that makes sense, however, Red Hat had
> >> backported that function starting with their RHEL5.9(*) kernels,
> >> yet the problem doesn't manifest on RHEL5.9.  Maybe the answer lies
> >> somewhere in RHEL5.9's do_wp_page(), or up that call path, but
> >> glancing through it, it all looks pretty close though.
> >>
> >>
> >> (*) That was the source I using when comparing with the 3.11 source
> >> when studying your patch since it was the last kernel known to me
> >> without the problem.
> >>
> >
> > I'm pretty sure RHEL5 has a similar problem, but it's unclear to me why
> > you're not seeing it there. I have a RHBZ open vs. RHEL5 but it's marked
> > private at the moment (I'll see about opening it up). I brought this up
> > upstream about a year ago with this strawman patch:
> >
> >     http://article.gmane.org/gmane.linux.nfs/51240
> >
> > ...at the time Trond said he was working on a set of patches to track
> > the open/lock stateid on a per-req basis. Did that approach not pan
> > out?
> >
> > Also, do you need to do a similar fix to nfs_can_coalesce_requests?
> >
> > Thanks,
> > --
> > Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@redhat.com>
