Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37069 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbaEEIxW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2014 04:53:22 -0400
Date: Mon, 5 May 2014 01:53:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 60/70] NFSd: Ensure lookup_clientid() takes client_lock
Message-ID: <20140505085316.GA21789@infradead.org>
References: <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-55-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-60-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-61-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-61-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
>  {
>  	__be32 status;
> @@ -3614,18 +3623,27 @@ static __be32 lookup_clientid(clientid_t *clid, struct nfsd4_session *session, s
>  {
>  	struct nfs4_client *found;
>  
> +	spin_lock(&nn->client_lock);
>  	if (session != NULL) {
>  		found = session->se_client;
>  		if (!same_clid(&found->cl_clientid, clid))
> -			return nfserr_stale_clientid;
> +			goto out_stale;

Do we really need the lock for the sessions case?  I don't tink
se_client can change under us.

Btw, I wonder if it makes sense to split the current lookup_clientid
into two helpers for the sessions vs non-sessions case as all but one
caller already have conditionals for 4.0 vs later anyway, so something
like:

static struct nfs4_client *client_from_session(struct nfsd4_session *session,
		clientid_t *clid)
{
	if (!same_clid(&session->se_client->cl_clientid, clid))
		return NULL;
	return session->se_client;
}

static __be32 lookup_40_client(clientid_t *clid, struct nfsd_net *nn,
	struct nfs4_client **clp)
{
	...
}

