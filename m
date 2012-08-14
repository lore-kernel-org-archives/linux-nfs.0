Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:37743 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab2HNSfQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 14:35:16 -0400
Date: Tue, 14 Aug 2012 19:35:12 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Richard Ems <richard.ems@cape-horn-eng.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
Message-ID: <20120814183512.GI23464@ZenIV.linux.org.uk>
References: <502A21A1.7020206@cape-horn-eng.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 14, 2012 at 06:04:08PM +0000, Myklebust, Trond wrote:
> > Is this a known BUG ?
> > Which other information or test can I do to contribute searching/resolving this issue?
> 
> I'm not 100% certain, but it looks to me as if the call to dget_parent()
> in nfs_lookup_revalidate is returning NULL.
> 
> Could you please apply the following patch, and see if that triggers the
> WARN_ON instead of the above Oops?

Unlikely as hell.  dget_parent() has only one return in it, and it's
        BUG_ON(!ret->d_count);
        ret->d_count++;
        spin_unlock(&ret->d_lock);
        return ret;
so it's extremely unlikely that it would managed to return NULL.  Not
without oopsing...
