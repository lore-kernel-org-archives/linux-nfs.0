Return-Path: bfields@fieldses.org
Date: Wed, 19 Nov 2014 15:55:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Client never uses DATA_SYNC
Message-ID: <20141119205538.GD14207@fieldses.org>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
 <20141105085317.GA18658@infradead.org>
 <20141105144133.GA3139@fieldses.org>
 <20141106201341.GD22638@fieldses.org>
 <20141107072637.GA25215@infradead.org>
 <20141107155307.GG22638@fieldses.org>
 <20141108070648.GA18993@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141108070648.GA18993@infradead.org>
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 07, 2014 at 11:06:48PM -0800, Christoph Hellwig wrote:
> On Fri, Nov 07, 2014 at 10:53:08AM -0500, J. Bruce Fields wrote:
> > By the way, the nfsd code is only using i_version when
> > IS_I_VERSION(inode), otherwise it falls back on ctime.  Do we have some
> > easy way to check for change attribute support now?  Otherwise we're
> > ignoring it on xfs and btrfs.
> 
> Both btrfs and xfs set MS_I_VERSION.  Btw, could you resend your patches
> to move this out of s_flags?

I didn't have much, and it's probably bit-rotted.  I'll look if I get a
chance but hope someone else will beat me to it....

--b.
