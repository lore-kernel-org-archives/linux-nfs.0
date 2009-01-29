From: Steven Patrick <steven-m+eqe7hsN2k@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 12564] New: poor performance while
	preprocessing source code
Date: Wed, 28 Jan 2009 17:02:36 -0800
Message-ID: <1233190956.21519.13.camel@bluishred.int.infinisim.com>
References: <bug-12564-10286@http.bugzilla.kernel.org/>
	 <20090128132942.c957a199.akpm@linux-foundation.org>
	 <20090128170506.37161fb6@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw.infinisim.com ([70.143.7.121]:38102 "EHLO mail.infinisim.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbZA2BCh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 20:02:37 -0500
In-Reply-To: <20090128170506.37161fb6-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-01-28 at 17:05 -0500, Jeff Layton wrote:
> 
> It's a pretty small patch. The obvious question is: "What mount
> options
> are you using on your NFS mounts?"
> 

  Well, I didn't think that I was using any NFS mounts.
But, it turns out I was in a way.  Apparently, amd does its top
level mounts with noac.  So, where this (using an automounted path):
    cd /h/spo/work
    make -j 5
would be slow.  This (using a non-automounted path):
    cd /home/spo/work
    make -j 5
showed the faster performance I was expecting.
  I will mark my bug as invalid and decide what, if anything,
I want to do about amd.
  Thanks for pointing me in the right direction.

Steven


