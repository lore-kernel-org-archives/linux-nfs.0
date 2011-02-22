Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5659 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757Ab1BVB1O convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 20:27:14 -0500
Subject: Re: [PATCH 4/7] NFSv4.1: trigger LAYOUTGET for writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <4D62B3BA.3060905@panasas.com>
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
	 <1298310576-13523-5-git-send-email-iisaman@netapp.com>
	 <4D62B3BA.3060905@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Feb 2011 17:27:12 -0800
Message-ID: <1298338032.4632.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-21 at 10:49 -0800, Benny Halevy wrote: 
> On 2011-02-21 09:49, Fred Isaman wrote:
> > @@ -965,11 +968,18 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
> >  	struct nfs_page		*req;
> >  	struct page		**pages;
> >  	struct nfs_write_data	*data;
> > +	int ret;
> >  
> >  	data = nfs_writedata_alloc(npages);
> > -	if (!data)
> > -		goto out_bad;
> > -
> > +	if (!data) {
> > +		while (!list_empty(head)) {
> > +			req = nfs_list_entry(head->next);
> 
> nit: it'd be cleaner to define a nfs_list_first_entry helper in nfs_page.h
> rather than using a combination of list helpers and open code (head->next).

No thanks! Let's not add lots of helpers for trivial stuff unless that
results in a clear gain in type safety.

   Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

