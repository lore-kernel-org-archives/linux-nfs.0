From: Neil Brown <neilb@suse.de>
Subject: Re: Man page update for timeo= and retrans= options.
Date: Tue, 8 Jan 2008 12:32:50 +1100
Message-ID: <18306.53954.61368.902438@notabene.brown>
References: <18301.39633.368089.130622@notabene.brown>
	<BA93E30A-817B-49B9-9703-FC77C2640BA5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45299 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753025AbYAHBc6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2008 20:32:58 -0500
In-Reply-To: message from Chuck Lever on Monday January 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday January 7, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> I just spent two months and rewrote all of nfs(5).  It should appear  
> in the next release of nfs-utils.  Steve, when can we expect to see  
> the updated man page?

I thought I had seem some rewrite go past, but it wasn't in my inbox
any more and also not it Steve's git so I just went ahead...

I see it is in the .git now (as of Friday).

Comments:
 - It says UDP defaults to 7/10 of a second, but
      nfs_init_timeout_values()
   says:
		if (!to->to_initval)
			to->to_initval = 11 * HZ / 10;

   which suggests 11/10 of a second.

 - It says 
    If the retrans option is not specified, the NFS client retries
    each request three times.

  but nfs_init_timeout_values() says

	if (!to->to_retries)
		to->to_retries = 2;

   which suggests it retries 2 time (or tries 3 times).


 - It says:
      After each retransmission, the NFS client doubles the timeout
      for that request, up to a maximum timeout length of 60 seconds.

   but doesn't (to me) make it clear that only applies to UDP.  For
   TCP, the timeouts appear to increase linearly up to 600 seconds.

Thanks,
NeilBrown
