Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37282 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933847AbeAITXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jan 2018 14:23:38 -0500
Date: Tue, 9 Jan 2018 14:23:38 -0500
To: Tamas Vincze <tom@vincze.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Varying ro/rw based on security flavor doesn't work
Message-ID: <20180109192338.GC18087@fieldses.org>
References: <890d00b1-fb64-1011-4a44-2e47713de0f7@vincze.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <890d00b1-fb64-1011-4a44-2e47713de0f7@vincze.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 09, 2018 at 10:11:05AM -0500, Tamas Vincze wrote:
> The exports man page says that one can vary ro/rw based on security
> flavor by including multiple sec= options in /etc/exports, but it
> seems to be broken in nfs-utils-1.3.0-0.48.el7_4.
> 
> For example this /etc/exports:
> 
> /export/pub 10.13.0.0/16(sec=sys,ro,sec=krb5i:krb5p,rw)
> 
> results in this /var/lib/nfs/etab:
> 
> /export/pub 10.13.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,secure,root_squash,no_all_squash,sec=krb5i:krb5p,secure,root_squash,no_all_squash)
> 
> Only the rw option is present in etab, that applies to both sec=sys
> and sec=krb5i:krb5p.
> 
> Is this bug specific to redhat or also present upstream?

I don't know off the top of my head....  Is there a redhat bug filed?
And is there some prevoius version that you know worked?

Agreed that it looks like a bug.

--b.
