Return-Path: <bfields@fieldses.org>
Date: Tue, 13 Sep 2016 16:39:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary
 allocation")
Message-ID: <20160913203901.GA21176@fieldses.org>
References: <20160901144839.6035.63068.stgit@klimt.1015granger.net>
 <20160906204238.GA30260@fieldses.org>
 <F9C6309A-2444-4B40-82D0-4BE90F19490A@oracle.com>
 <20160906210149.GB30260@fieldses.org>
 <B18D986B-5CC2-4D73-AD9C-525DBB4B93AD@oracle.com>
 <9417A81A-BEBF-4B46-AF44-98B59D23D183@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9417A81A-BEBF-4B46-AF44-98B59D23D183@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 06, 2016 at 07:49:31PM -0400, Benjamin Coddington wrote:
> On 6 Sep 2016, at 17:25, Chuck Lever wrote:
> 
> >> On Sep 6, 2016, at 5:01 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>
> >> On Tue, Sep 06, 2016 at 04:49:33PM -0400, Chuck Lever wrote:
> >>>
> >>> On Sep 6, 2016, at 4:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>>> Apologies, I wasn't thinking when I wrote that patch.  The problem is
> >>>> probably that rsc_lookup steals the passed-in memory to avoid doing an
> >>>> allocation of its own, so we can't just pass in a pointer to memory that
> >>>> someone else is using....
> >>>>
> >>>> If we really want to avoid allocation there then maybe we should
> >>>> preallocate somwhere, or reference count these handles.
> >>>>
> >>>> For now reverting sounds like the right thing to do.
> >>>
> >>> NP, thanks for confirming!
> >>>
> >>>
> >>>> Ben, did you ever confirm whether this helped with the problem you were
> >>>> seeing?  (If I remember correctly, unnpredictable delays here could
> >>>> cause the request to be dropped if later requests push the rpcsec_gss
> >>>> sequence window too far.)  If so then we could look into reference
> >>>> counting.
> 
> I somehow missed this; I haven't tested it.

OK.  If you get a reliable reproducer for the reordering problem, we can
revisit this, till then I'm not going to worry about it (and meanwhile
Chuck's work to close on dropping should mitigate the symptoms).

--b.
