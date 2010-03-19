From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: Re: nfs: server not responding, timed out
Date: Fri, 19 Mar 2010 10:21:57 +0800
Message-ID: <4BA2DFC5.1010400@cn.fujitsu.com>
References: <20100318170603.f6a7f188.dennisn@dennisn.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org
To: Dennis Nezic <dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60884 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751957Ab0CSCW1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Mar 2010 22:22:27 -0400
In-Reply-To: <20100318170603.f6a7f188.dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> After upgrading my server (kernel 2.6.19 to 2.6.33, nfs-utils 1.1.0 to
> 1.2.1/1.1.4/1.1.6), and probably other stuff too), and possibly my
> client laptop's kernel, I have suddenly started to get these "server X
> not responding, timed out" errors (on my client), especially (only?)
> when doing large file transfers. This would lead to input/output
> errors, and the transfers would fail.
> 
> I never noticed any such problems for over two years, using the older
> versions. The networking (wifi link) hasn't changed.
> 
> Usually the file transfer trips and falls over itself near the end --
> Ie. it will do 600MB out of 800MB just fine, and then suddently start
> giving these "timed out" errors, and then crash and burn. At this
> point, I am forced to "umount -fl" the mount. If I then try to remount
> it, the server acnowledges my "authenticated mount requests" perfectly
> fine, but my client (laptop) still appears "hung". After a few minutes,
> I am able to remount it.
> 
> I tried playing with the rsize/wsize/timeo/retrans variables, but none
> of it seemed to fix the problem.
> 
> Any ideas about what has changed? Maybe this is/was a well-known
> problem? :P
> 

  I do not know the what's the reason. And I am not sure the followed discussion
  can fix this problem, but maybe it can help you.
  http://marc.info/?l=linux-nfs&m=123478426412524&w=2

Best Regards
 Bian

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

