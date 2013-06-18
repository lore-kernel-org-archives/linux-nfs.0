Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38184 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754497Ab3FRROi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jun 2013 13:14:38 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UozUL-0002yr-HK
	for linux-nfs@vger.kernel.org; Tue, 18 Jun 2013 13:14:37 -0400
Date: Tue, 18 Jun 2013 13:14:37 -0400
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH]: gssd: Fix preferred_realm option handling
Message-ID: <20130618171437.GA9915@fieldses.org>
References: <20130611093403.GB27345@principal.rfc2324.org>
 <20130611114114.GB16756@umich.edu>
 <20130617170247.GA16125@principal.rfc2324.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130617170247.GA16125@principal.rfc2324.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 17, 2013 at 07:02:47PM +0200, Maximilian Wilhelm wrote:
> Anno domini 2013 Jim Rees scripsit:
> 
> > Maximilian Wilhelm wrote:
> 
> >   +	 * Make sure the preferred_realm (which may have been explicitly set
> >   +	 * on the command line, is tried first. If nothing is found go on with
> >   +	 * the host and local default realm (if that hasn't already been tried).
> 
> > You're missing a close paren there somewhere.
> 
> Indeed. The first '(' should have been a ','.
> 
> Anyone willing to apply this?

Note nfs-utils patches should go to steved@redhat.com, cc'd to this
list.

But also note this is the week of the Ann Arbor bakeathon so many of us
will be less responsive this week.

--b.
