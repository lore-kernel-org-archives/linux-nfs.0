Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab3FDMP4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 08:15:56 -0400
Date: Tue, 4 Jun 2013 08:15:17 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, viro@zeniv.linux.org.uk,
        matthew@wil.cx, dhowells@redhat.com, sage@inktank.com,
        smfrench@gmail.com, swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: Re: [PATCH v1 00/11] locks: scalability improvements for file
 locking
Message-ID: <20130604081517.0ad9f983@corrin.poochiereds.net>
In-Reply-To: <20130604115644.GA4180@umich.edu>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<20130603213101.GC2109@fieldses.org>
	<20130604065417.46080a57@tlielax.poochiereds.net>
	<20130604115644.GA4180@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 4 Jun 2013 07:56:44 -0400
Jim Rees <rees@umich.edu> wrote:

> Jeff Layton wrote:
> 
>   > Might be nice to look at some profiles to confirm all of that.  I'd also
>   > be curious how much variation there was in the results above, as they're
>   > pretty close.
>   > 
>   
>   The above is just a random representative sample. The results are
>   pretty close when running this test, but I can average up several runs
>   and present the numbers. I plan to get a bare-metal test box on which
>   to run some more detailed testing and maybe some profiling this week.
> 
> Just contributing more runs into the mean doesn't tell us anything about the
> variance. With numbers that close you need the variance to tell whether it's
> a significant change.

Thanks. I'll see if I can get some standard deviation numbers here, and
I'll do it on some bare metal to ensure that virtualization doesn't
skew any results.

FWIW, they were all consistently very close to one another when I ran
these tests, and the times were all consistently shorter than the
unpatched kernel.

That said, this test is pretty rough. Doing this with "time" measures
other things that aren't related to locking. So I'll also see if I
can come up with a way to measure the actual locking performance more
accurately too.

-- 
Jeff Layton <jlayton@redhat.com>
