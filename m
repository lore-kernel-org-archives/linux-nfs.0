Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40347 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126Ab2CWREI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 13:04:08 -0400
Date: Fri, 23 Mar 2012 13:04:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v10 3/8] sunrpc: create nfsd dir in rpc_pipefs
Message-ID: <20120323170405.GA6089@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <1332337929-18580-4-git-send-email-jlayton@redhat.com>
 <20120323121208.GA3219@fieldses.org>
 <20120323133111.GA2991@fieldses.org>
 <1332516024.3087.1.camel@lade.trondhjem.org>
 <20120323152220.GA4953@fieldses.org>
 <1332516863.3087.10.camel@lade.trondhjem.org>
 <20120323115337.28bff808@corrin.poochiereds.net>
 <20120323121218.74461807@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120323121218.74461807@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 23, 2012 at 12:12:18PM -0400, Jeff Layton wrote:
> ...and contrary to what Bruce has seen, I can also reproduce this when
> the server is running a stock (unpatched) 3.3.0 kernel from the Fedora
> rawhide repos.

Yeah, there may just be some subtle timing difference that makes it
reproduce for me with that patch applied and not without it.  It's
clearly a preexisting bug not directly relevant to this patch.

I'll keep looking.

--b.
