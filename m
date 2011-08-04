Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:39413 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab1HDMEE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 08:04:04 -0400
Date: Thu, 4 Aug 2011 08:04:01 -0400
From: Jim Rees <rees@umich.edu>
To: Max Matveev <makc@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] Update nfs(5) manpage - timeo for NFS/TCP
Message-ID: <20110804120401.GB9984@merit.edu>
References: <20026.13331.411712.805796@regina.usersys.redhat.com>
 <20110804062858.EAD96813270B@regina.usersys.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110804062858.EAD96813270B@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Max Matveev wrote:

  NFS/TCP does linear backoff then retransmiting - the manpage
  was mistakenly asserting the "no backoff" theory.
  
  Signed-off-by: Max Matveev <makc@redhat.com>
  ---
   utils/mount/nfs.man |   14 +++++++++-----
   1 files changed, 9 insertions(+), 5 deletions(-)
  
  diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
  index be91a25..7681b10 100644
  --- a/utils/mount/nfs.man
  +++ b/utils/mount/nfs.man
  @@ -114,11 +114,15 @@ option.
   .TP 1.5i
   .BI timeo= n
   The time (in tenths of a second) the NFS client waits for a
  -response before it retries an NFS request. If this
  -option is not specified, requests are retried every
  -60 seconds for NFS over TCP.
  -The NFS client does not perform any kind of timeout backoff
  -for NFS over TCP.
  +response before it retries an NFS request.
  +.IP
  +For NFS over TCP the default
  +.B timeo
  +value is 600 which equals to 60 seconds.
  +The NFS client performs linear backoff  -
  +after each retransmission the timeout is increased by
  +.BR timeo /10
  +seconds upto the maximum of 600 seconds.

"upto" should be "up to".

I'm not crazy about the wording.  How about

  For NFS over TCP the default timeo is 600 (60 seconds).  The NFS client
  performs linear backoff.  After each retransmission the timeout is
  increased by timeo up to the maximum of 600 seconds.

Finally, I would call them "deciseconds".

timeo: The time in deciseconds (tenths of a second) ...
