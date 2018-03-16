Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36370 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752579AbeCPOnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Mar 2018 10:43:49 -0400
Date: Fri, 16 Mar 2018 10:43:49 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 3/3] nfsd: clients don't need to break their own
 delegations
Message-ID: <20180316144349.GH18719@fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-4-git-send-email-bfields@redhat.com>
 <87bmn0ia6i.fsf@notabene.neil.brown.name>
 <20170829214907.GJ8822@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170829214907.GJ8822@parsley.fieldses.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 29, 2017 at 05:49:07PM -0400, J. Bruce Fields wrote:
> Now we get to harder questions....
> 
> On Mon, Aug 28, 2017 at 02:32:53PM +1000, NeilBrown wrote:
> > Would this all turn out to be easier if nfsd took a separate lease for
> > each client?  What would be the cost of that?
> 
> I'll have to remind myself.

OK, done and I think it's actually nicer that way.  I'll post the whole
series later today.

--b.
