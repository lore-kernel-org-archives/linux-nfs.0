Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41221 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab2E2NNd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 09:13:33 -0400
Date: Tue, 29 May 2012 09:13:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH] NFSD: TEST_STATEID should not return
 NFS4ERR_STALE_STATEID
Message-ID: <20120529131330.GB2308@fieldses.org>
References: <20120524192932.8296.44698.stgit@lebasque.1015granger.net>
 <20120525134636.GA28842@fieldses.org>
 <62C4F65F-B822-4B00-B7AC-185EF14E39D8@oracle.com>
 <B7E9175E-01AF-400D-9490-3E82F74478D5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B7E9175E-01AF-400D-9490-3E82F74478D5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 27, 2012 at 04:30:24PM -0400, Chuck Lever wrote:
> Hi-
> 
> On May 25, 2012, at 7:30 PM, Chuck Lever wrote:
> 
> > On May 25, 2012, at 9:46 AM, J. Bruce Fields wrote:
> > 
> >> If you think it's worth checking for those buggy client cases, we could
> >> instaed check that stateid->si_opaque.so_clid and cl->clientid agree.
> >> That'd cover the special-stateid checks too.
> > 
> > That's interesting.  I can redrive this patch with this change.
> 
> Doesn't a positive find_stateid(cl, stateid) result guarantee that so_clid and clientid are the same?

No, it only looks at the si_opaque.so_id, and assumes this stateid
belongs to the given client.  The passed-in client was actually
extracted from the sequence at the start of the compound:

	nfsd4_sequence(...)
	{
		...
		session = find_in_sessionid_hashtbl(&seq->sessionid);
		...
		cstate->session = session;
	}

	nfsd4_free_stateid(...)
	{
		struct nfs4_client *cl = cstate->session->se_client;
		...
			... nfs4_validate_stateid(cl, &stateid->ts_id_stateid);
	}

So in theory a confused client sent a free_stateid referencing a stateid
that belonged to a client other than the one that the session belonged
to, and then we'd see this inconsistency.

--b.
