Return-Path: <bfields@fieldses.org>
Date: Tue, 6 Sep 2016 17:01:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, bcodding@redhat.com
Subject: Re: [PATCH] svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary
 allocation")
Message-ID: <20160906210149.GB30260@fieldses.org>
References: <20160901144839.6035.63068.stgit@klimt.1015granger.net>
 <20160906204238.GA30260@fieldses.org>
 <F9C6309A-2444-4B40-82D0-4BE90F19490A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F9C6309A-2444-4B40-82D0-4BE90F19490A@oracle.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 06, 2016 at 04:49:33PM -0400, Chuck Lever wrote:
> 
> On Sep 6, 2016, at 4:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Apologies, I wasn't thinking when I wrote that patch.  The problem is
> > probably that rsc_lookup steals the passed-in memory to avoid doing an
> > allocation of its own, so we can't just pass in a pointer to memory that
> > someone else is using....
> > 
> > If we really want to avoid allocation there then maybe we should
> > preallocate somwhere, or reference count these handles.
> > 
> > For now reverting sounds like the right thing to do.
> 
> NP, thanks for confirming!
> 
> 
> > Ben, did you ever confirm whether this helped with the problem you were
> > seeing?  (If I remember correctly, unnpredictable delays here could
> > cause the request to be dropped if later requests push the rpcsec_gss
> > sequence window too far.)  If so then we could look into reference
> > counting.
> 
> Well that's interesting.
> 
> When a request is dropped, would the server disconnect? Because if it
> doesn't, the client will wait forever.

Checking... gss_verify_header returns SVC_DROP, which is just a silent
close (SVC_CLOSE would close the connection).

I'm not sure what's correct there.

--b.
