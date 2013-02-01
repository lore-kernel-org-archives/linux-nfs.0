Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:35346 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab3BAAIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2013 19:08:23 -0500
Date: Thu, 31 Jan 2013 16:08:12 -0800
From: Tejun Heo <tj@kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/14] nfs: idr_destroy() no longer needs idr_remove_all()
Message-ID: <20130201000812.GO6824@mtj.dyndns.org>
References: <1359163872-1949-1-git-send-email-tj@kernel.org>
 <1359163872-1949-12-git-send-email-tj@kernel.org>
 <20130129225848.GD6219@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9183426FE@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9183426FE@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond.

On Wed, Jan 30, 2013 at 02:18:06AM +0000, Myklebust, Trond wrote:
> My worry is more about Tejun's comment that we did actually need a call
> to idr_remove_all() in the original code. Do we need to queue up a fix
> for the 3.8 and existing stable kernels?

IIUC, the only case where idr_layer is left around after idr_remove()
on all elems is when the deletions lead to multi-level left-most
collapse.  Not sure whether the current code can actually hit that.
No harm in adding idr_remove_all(), I guess.

Thanks.

-- 
tejun
