Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:50420 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaDUNba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:31:30 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so1757349igb.5
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 06:31:29 -0700 (PDT)
Message-ID: <1398087088.2891.16.camel@leira.trondhjem.org>
Subject: Re: [PATCH 35/70] NFSd: Slight cleanup of find_stateid()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 21 Apr 2014 09:31:28 -0400
In-Reply-To: <20140419144153.GD25682@infradead.org>
References: <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
	 <20140419144153.GD25682@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-04-19 at 07:41 -0700, Christoph Hellwig wrote:
> > +static struct nfs4_stid *find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
> >  {
> >  	struct nfs4_stid *ret;
> >  
> > -	spin_lock(&cl->cl_lock);
> >  	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
> > -	spin_unlock(&cl->cl_lock);
> >  	if (!ret || !ret->sc_type)
> >  		return NULL;
> 
> Just curious, how can !ret->sc_type happen?
> 

At least for open and lock stateids, the ret->sc_type field isn't
initialised until nfsd4_process_open2() and alloc_init_lock_stateid() so
there is a small window where they are visible to the idr tree while not
being fully initialised.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


