From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/10] nfs41: adjust max_rqst_sz, max_resp_sz w.r.t to
	rsize, wsize
Date: Tue, 24 Nov 2009 15:39:23 -0500
Message-ID: <20091124203923.GA29856@fieldses.org>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com> <1259017040.8700.94.camel@localhost> <4B0C2FA2.8000207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932945AbZKXUio (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:38:44 -0500
In-Reply-To: <4B0C2FA2.8000207@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2009 at 02:10:26PM -0500, Peter Staubach wrote:
> Trond Myklebust wrote:
> > 
> > Is anyone ever going to use NFSv4.1 over UDP?
> > 
> 
> I thought that NFSv4 over UDP was outlawed because UDP, as
> a transport, did not offer the correct set of semantics
> required.  I know that the Linux NFSv4 server registers
> NFSv4 over UDP, but I don't know of any other servers which
> do.
> 
> I was going to file a bug and a patch to stop NFSv4 from
> being transported over UDP.  :-)

OK by me.--b.
