Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60974 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab3EPUWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 May 2013 16:22:31 -0400
Date: Thu, 16 May 2013 16:22:29 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Speed up detection of whether or not rpc.gssd is
 running
Message-ID: <20130516202228.GC3216@fieldses.org>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
 <14F7EF8E-A5C7-4187-B53A-EA71283AFC3A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14F7EF8E-A5C7-4187-B53A-EA71283AFC3A@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 16, 2013 at 09:55:21AM -0400, Chuck Lever wrote:
> 
> On May 15, 2013, at 3:50 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> 
> > Also fix the auth_gss pipe version detection so that it works
> > correctly in the presence of namespaces.
> 
> Obviously my preference is to keep the existing krb5i -> sys logic and
> to try to address the upcall timeout, so this is a good direction,
> IMO.
> 
> After some review, I'm still a little concerned about initialization
> races inappropriately preventing upcalls,

I don't understand what you're referring to--could you elaborate?

--b.

> but time (and testing) will
> tell.  I'm happy with this solution if you and Bruce are.
> 
> Speaking of testing, I can test this series if you think that would be
> valuable, but I assume that those who originally reported the timeout
> problem (Jeff and Steve) should be the ones to confirm whether this
> series addresses their concern.
> 
> 
> > Trond Myklebust (3): SUNRPC: Fix a bug in gss_create_upcall SUNRPC:
> > Faster detection if gssd is actually running SUNRPC: Convert
> > auth_gss pipe detection to work in namespaces
> > 
> > net/sunrpc/auth_gss/auth_gss.c | 62
> > ++++++++++++++++++++++++++++-------------- net/sunrpc/netns.h
> > |  4 +++ net/sunrpc/rpc_pipe.c          |  5 ++++ 3 files changed,
> > 50 insertions(+), 21 deletions(-)
> 
> -- Chuck Lever chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> -- To unsubscribe from this list: send the line "unsubscribe
> linux-nfs" in the body of a message to majordomo@vger.kernel.org More
> majordomo info at  http://vger.kernel.org/majordomo-info.html
