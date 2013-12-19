Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895Ab3LSS57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Dec 2013 13:57:59 -0500
Date: Thu, 19 Dec 2013 13:57:45 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: Benny Halevy <bhalevy@primarydata.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd4: ignore nfsv4.1 lockowners in
 nfsd4_release_lockowner
Message-ID: <20131219185745.GB6951@fieldses.org>
References: <52AADAF6.40700@primarydata.com>
 <1386929026-12627-1-git-send-email-bhalevy@primarydata.com>
 <20131213141243.GA20399@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131213141243.GA20399@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 13, 2013 at 06:12:43AM -0800, Christoph Hellwig wrote:
> >  	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> >  		if (sop->so_is_open_owner)
> >  			continue;
> > +		if (sop->so_client->cl_minorversion)
> > +			continue;
> >  		if (!same_owner_str(sop, owner, clid))
> >  			continue;
> >  		list_for_each_entry(stp, &sop->so_stateids,
> 
> This needs at least a good comment as it's not very obvious from
> glancing over the code.  That being said is same_owner_str so much
> overhead that it's really worth it?
> 

Right, this seems redundant with the cli_id comparison in
same_owner_str.  That could be reordered to ensure it precedes the
memcmp if we think that's worthwhile.

--b.
