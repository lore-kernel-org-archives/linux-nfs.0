Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40111 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942829AbdEYQ7G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 May 2017 12:59:06 -0400
Date: Thu, 25 May 2017 09:59:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        Weston Andros Adamson <dros@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] nfs: test nfs4_getfacl near page size ACL from server
Message-ID: <20170525165905.GA17207@infradead.org>
References: <20170516120909.827-1-eguan@redhat.com>
 <20170516150745.GB21704@parsley.fieldses.org>
 <20170517033854.GA7250@eguan.usersys.redhat.com>
 <20170517172035.GD5011@parsley.fieldses.org>
 <20170525040119.GB23805@eguan.usersys.redhat.com>
 <20170525132625.GA6658@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170525132625.GA6658@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 25, 2017 at 09:26:25AM -0400, J. Bruce Fields wrote:
> On Thu, May 25, 2017 at 12:01:19PM +0800, Eryu Guan wrote:
> > Yes, that's a problem, it's been 'xfstests' for at least 14 years and
> > 'fstests' is only there for 3 years, sometimes (or most of the times) we
> > still call it 'xfstests' for a better understanding.
> 
> Just to troll slightly: I actually don't believe you when you say it's
> been renamed.  I don't see any evidence of that.

The only thing that seems to be called fstests is the mailing list.
I was very much against that name back then, but DAve won the fight.
I don't think it's been very helpful evern retrospectively.
