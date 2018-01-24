Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34892 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932083AbeAXAre (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jan 2018 19:47:34 -0500
Message-ID: <1516754851.18068.3.camel@gmail.com>
Subject: Re: [PATCH 1/4] lockd: convert nlm_host.h_count from atomic_t to
 refcount_t
From: Trond Myklebust <trondmy@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
Date: Tue, 23 Jan 2018 19:47:31 -0500
In-Reply-To: <20180123220950.GA5632@fieldses.org>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
         <1511954146-11793-2-git-send-email-elena.reshetova@intel.com>
         <20171221202350.GE31467@fieldses.org>
         <2236FBA76BA1254E88B949DDB74E612B802CFB57@IRSMSX102.ger.corp.intel.com>
         <20171222142553.GA9630@fieldses.org> <20171222154250.GB9630@fieldses.org>
         <2236FBA76BA1254E88B949DDB74E612B802D08DA@IRSMSX102.ger.corp.intel.com>
         <20180123220950.GA5632@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-01-23 at 17:09 -0500, J. Bruce Fields wrote:
> 
> The object still has useful information in it so we can't just
> reinitalize it completely.  I guess we could make nlm_get_host do
> 
> 	if (refcount_read(&host->h_count))
> 		refcount_inc(&host->h_count);
> 	else
> 		refcount_set(&host->h_count, 1);
> 
> Or we could just change the code so the refcount is always 1 higher
> in
> the NFS server case, so "1" instead of "0" is used to mean "nobody's
> using this, you can garbage collect this", and then it won't go to 0
> until the garbage collector actually destroys it.
> 
> This isn't an unusual pattern, what have other subsystems been doing?
> 

Hi Bruce,

Sorry I forgot about the issues with the server garbage collector, and
I applied these patches to my linux-next a couple of weeks ago.

What say we fix the issue with something like the following?

8<------------------------------------------------------------
