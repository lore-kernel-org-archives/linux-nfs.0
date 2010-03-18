From: Dennis Nezic <dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Subject: nfs: server not responding, timed out
Date: Thu, 18 Mar 2010 17:06:03 -0400
Message-ID: <20100318170603.f6a7f188.dennisn@dennisn.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:45359 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773Ab0CRVKF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Mar 2010 17:10:05 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1NsMyh-00051L-K0
	for linux-nfs@vger.kernel.org; Thu, 18 Mar 2010 22:10:03 +0100
Received: from 67.55.41.152 ([67.55.41.152])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Mar 2010 22:10:03 +0100
Received: from dennisn by 67.55.41.152 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Mar 2010 22:10:03 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After upgrading my server (kernel 2.6.19 to 2.6.33, nfs-utils 1.1.0 to
1.2.1/1.1.4/1.1.6), and probably other stuff too), and possibly my
client laptop's kernel, I have suddenly started to get these "server X
not responding, timed out" errors (on my client), especially (only?)
when doing large file transfers. This would lead to input/output
errors, and the transfers would fail.

I never noticed any such problems for over two years, using the older
versions. The networking (wifi link) hasn't changed.

Usually the file transfer trips and falls over itself near the end --
Ie. it will do 600MB out of 800MB just fine, and then suddently start
giving these "timed out" errors, and then crash and burn. At this
point, I am forced to "umount -fl" the mount. If I then try to remount
it, the server acnowledges my "authenticated mount requests" perfectly
fine, but my client (laptop) still appears "hung". After a few minutes,
I am able to remount it.

I tried playing with the rsize/wsize/timeo/retrans variables, but none
of it seemed to fix the problem.

Any ideas about what has changed? Maybe this is/was a well-known
problem? :P

