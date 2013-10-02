Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753697Ab3JBP1d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 11:27:33 -0400
Date: Wed, 2 Oct 2013 11:26:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Benny Halevy <bhalevy@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
Message-ID: <20131002152647.GD2002@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
 <20130929121903.GF21083@infradead.org>
 <524ACEA9.1040304@primarydata.com>
 <20131001133739.GA13149@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131001133739.GA13149@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 01, 2013 at 06:37:39AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 01, 2013 at 04:31:21PM +0300, Benny Halevy wrote:
> > So the reason not to hold it is that the nfs state lock is global to the
> > server and blocks all state modifying operations such as:
> > open, close, lock, clientid, session operations, etc.
> 
> While not really related to this patch: what's the reason it's not
> split?  The way nfsd works there should be almost no state that isn't
> per-export.

There's the NFSv4 client, but yes, the global state lock is an
embarassment....

--b.
