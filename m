From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
	specified by user
Date: Tue, 1 Sep 2009 14:50:11 -0400
Message-ID: <20090901185011.GC27726@fieldses.org>
References: <20090901143012.3978.11441.stgit@matisse.1015granger.net> <20090901150545.GA22846@fieldses.org> <7C5C14D9-F315-4DF8-A2F4-C7F0981AC968@oracle.com> <20090901151830.GC22846@fieldses.org> <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com> <20090901160914.GG22846@fieldses.org> <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com> <20090901163846.GJ22846@fieldses.org> <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com> <4A9D690E.2050704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbZIASuR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 14:50:17 -0400
In-Reply-To: <4A9D690E.2050704@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2009 at 02:33:50PM -0400, Peter Staubach wrote:
> Chuck Lever wrote:
> > 
> > On Sep 1, 2009, at 12:38 PM, J. Bruce Fields wrote:
> > 
> >> On Tue, Sep 01, 2009 at 12:29:30PM -0400, Chuck Lever wrote:
> >>> On Sep 1, 2009, at 12:09 PM, J. Bruce Fields wrote:
> >>>> And, sure, that'd be OK with me, and would probably be better than
> >>>> adding another exception, so I'm OK with skipping #3.  (We definitely
> >>>> shouldn't omit #2, though.)
> >>>
> >>> Seems straightforward enough, but...  Why are we doing this again?  It
> >>> still seems like non-standard behavior.  Are we simply attempting to
> >>> avoid the case where folks would get the "nobody" behavior unexpectedly
> >>> because of a mountd bug, or is there more to it?
> >>
> >> That's all there is to it.  As I said:
> >>
> >>>>>>>>     2. In the absence of sec=, we should probably *not* choose
> >>>>>>>>     AUTH_NULL.  (All mountd's before 1.1.3 list AUTH_NULL first on
> >>>>>>>>     the returned list, so users with older servers may wonder why a
> >>>>>>>>     client upgrade is making files they create suddenly be owned by
> >>>>>>>>     nobody.) http://marc.info/?l=linux-nfs&m=125089022306281&w=2
> >>
> >>> I'm just thinking of what the documenting comment might say, and perhaps
> >>> some explanation added to nfs(5).
> >>
> >> "As a special case, to work around bugs in some older servers, the
> >> client will never automatically negotiate auth_null; if auth_null is
> >> desired, an explicit "sec=null" on the commandline is required."
> >>
> >> Or something like that.
> > 
> > OK, one more corner case.
> > 
> > What if the mount doesn't specify "sec=" and the only flavor in the
> > server's auth list is AUTH_NULL?  Seems like we should allow that one.
> > 
> 
> Some servers will accept any flavor of incoming RPC security
> and just use AUTH_NULL in this situation.  It really shouldn't
> matter what the client sends, as long as the server is just
> going to map all requests to nobody/nobody anyway...

OK, but let's not pile on more workarounds than we have to.  I don't see
any reason that we really need to do anything special for servers that
are broken in *that* particular way....

--b.
