From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Exportfs and rpc.mountd optimalization (revisited)
Date: Fri, 20 Feb 2009 13:31:46 -0500
Message-ID: <20090220183146.GD1104@fieldses.org>
References: <499C5861.6050408@RedHat.com> <20090219174118.GA15743@fieldses.org> <499EC930.2030408@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:49441 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbZBTSbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2009 13:31:46 -0500
In-Reply-To: <499EC930.2030408-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 20, 2009 at 10:16:00AM -0500, Steve Dickson wrote:
> 
> 
> J. Bruce Fields wrote:
> > On Wed, Feb 18, 2009 at 01:50:09PM -0500, Steve Dickson wrote:
> >> Very long time ago Tomas Richter submitted a patch that added
> >> a export hash table to both exportfs and mountd. Very recently 
> >> I ran across it and actually used some parts in the recent TCP
> >> wrappers patch... 
> >>
> >> Looking at the discussion 
> >>     http://marc.info/?l=linux-nfs&m=111938362106991&w=2
> >> It seem no one took the time to test out the patch.. There
> >> was even a Red Hat bug opened on it but for some reason
> >> it got closed... Anyway... 
> >>
> >> This is a good patch... imho.. It does help with very large exports 
> >> at least in my testing...
> > 
> > Just out of curiosity--what's your test?
> Created a couple hundred exports. Then used the 'time' command to
> see how long 'exportfs -arv' took. Plus I timed how long it took a
> client mount... I did to this a while ago, but as I remember it 
> was a big win with this patch... 

Sounds good.  But I'm surprised a couple hundred is all it takes--that's
not such a long list to search!  It would be interesting to take a
closer look and do some profiling.

--b.
