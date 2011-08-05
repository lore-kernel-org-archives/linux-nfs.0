Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:49182 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216Ab1HENe7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Aug 2011 09:34:59 -0400
Date: Fri, 5 Aug 2011 09:34:56 -0400
From: Jim Rees <rees@umich.edu>
To: Max Matveev <makc@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
Message-ID: <20110805133456.GA17018@merit.edu>
References: <20110805021903.C84608198734@regina.usersys.redhat.com>
 <20110805124015.GA16926@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110805124015.GA16926@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim Rees wrote:

  Max Matveev wrote:
  
    NFS/TCP does linear backoff then retransmiting - the manpage
    was mistakenly asserting the "no backoff" theory.
  
  Actually, now that I made you change the wording, I think the original
  wording was correct.  "Backoff" refers to an increase in the interval
  between retries.  Since the interval is constant, there is no backoff.

Check this:

http://www.cs.utexas.edu/users/lam/NRL/backoff.html

So NFS over TCP uses a fixed retry interval, not a linear one.  I don't
think it's correct to say "no backoff" but it's also not correct to say it's
"linear backoff," which implies the retry interval is linear in the number
of retries (you could argue that it's linear and the slope is zero but I
think that's misleading).  The correct term might be "fixed backoff" or
"fixed retry interval."
