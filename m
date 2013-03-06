Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f51.google.com ([209.85.213.51]:58061 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126Ab3CFBjY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 20:39:24 -0500
Received: by mail-yh0-f51.google.com with SMTP id q1so1134168yhf.24
        for <linux-nfs@vger.kernel.org>; Tue, 05 Mar 2013 17:39:23 -0800 (PST)
Date: Tue, 5 Mar 2013 17:16:23 -0800
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mandeep Singh Baines <msb@chromium.org>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>, Ming Lei <ming.lei@canonical.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306011623.GG1227@htj.dyndns.org>
References: <20130304092310.1d21100c@tlielax.poochiereds.net>
 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
 <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305231110.GK15816@fieldses.org>
 <CACBanvo+JDCFVRQeTQwnwRRxr8bdqxdsgeEr8fqgJhGQJEEQ-Q@mail.gmail.com>
 <20130306010507.GL15816@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130306010507.GL15816@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 05, 2013 at 08:05:07PM -0500, J. Bruce Fields wrote:
> If it's really just a 2-line patch to try_to_freeze(), could it just be
> carried out-of-tree by people that are specifically working on tracking
> down these problems?
> 
> But I don't have strong feelings about it--as long as it doesn't result
> in the same known issues getting reported again and again....

Agreed, I don't think a Kconfig option is justified for this.  If this
is really important, annotate broken paths so that it doesn't trigger
spuriously; otherwise, please just remove it.

Thanks.

-- 
tejun
