Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53476 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741AbaHESqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 14:46:55 -0400
Date: Tue, 5 Aug 2014 14:46:44 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Jeffrey Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 31/38] nfsd: Move the open owner hash table into
 struct nfs4_client
Message-ID: <20140805184644.GR23341@fieldses.org>
References: <1406684083-19736-32-git-send-email-jlayton@primarydata.com>
 <53DCBFDB.5060808@gmail.com>
 <CAHQdGtTGNZsqZTCQhUboG1kE+bzb7p3K+5BxmusFG+qWMrVJzg@mail.gmail.com>
 <53DCEAE8.70707@gmail.com>
 <CAHQdGtT4qb_KkLYcM64z8=YY-J3pheKBb_-pvVQvpVmpWFh=1A@mail.gmail.com>
 <53DCF3C0.6050201@gmail.com>
 <CAHQdGtRNwSbhKkfbop-8NFq6WTS_EmrojC2HyLmkKki94oxSHw@mail.gmail.com>
 <20140802185933.64ba0b15@tlielax.poochiereds.net>
 <CAHQdGtS+X1KABsr5buxKqC5VNpyWBrJYMD74HzWtF=fDOs19bg@mail.gmail.com>
 <CAPakX04ctGujqpJ48WqT1-r5=q0T8D1Ji=q1P5UTuwdw_hTsGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPakX04ctGujqpJ48WqT1-r5=q0T8D1Ji=q1P5UTuwdw_hTsGg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 03, 2014 at 07:35:37AM -0400, Jeffrey Layton wrote:
> Agreed. That's a significant bit of nastiness, and I think you're
> correct that the client_mutex removal will exacerbate the problem. The
> only way I can see to properly fix that would be to make it so that
> the conflock holds a reference to the lockowner, and then put it when
> the conflock is freed.
> 
> That will require some new fl_ops or fl_lmops. It would also be good
> to clean up conflock generation a bit, and turn it into a more
> explicit process.  __locks_copy_lock doesn't really fully describe
> what's going on there, IMO...

Or do the work of nfs4_set_lock_denied under the i_lock in some sort of
callback from the locking code?

--b.
