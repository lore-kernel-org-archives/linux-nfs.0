From: bpm@sgi.com
Subject: Re: [PATCH] mountd: use separate lockfiles
Date: Wed, 25 Mar 2009 09:47:18 -0500
Message-ID: <20090325144718.GL16509@sgi.com>
References: <20090319172841.GF26378@sgi.com> <1237485682.7534.39.camel@heimdal.trondhjem.org> <20090319195357.GH26378@sgi.com> <20090319221458.GI26378@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:35952 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755593AbZCYOpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 10:45:01 -0400
In-Reply-To: <20090319221458.GI26378@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Steve,

On Thu, Mar 19, 2009 at 05:14:58PM -0500, Ben Myers wrote:
> On Thu, Mar 19, 2009 at 02:53:57PM -0500, Ben Myers wrote:
> > On Thu, Mar 19, 2009 at 02:01:21PM -0400, Trond Myklebust wrote:
> > > Why do you need a second call to open() in the first place?
> > I'll give it another try.
> 
> Here it is again.  It works just fine without the second open.

Have you had a chance to take a look at this patch?

Thanks,
	Ben
