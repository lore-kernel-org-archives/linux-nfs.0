From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] Should lockd get into grace_period when statd start but not
 stop?
Date: Wed, 10 Mar 2010 18:22:35 +0800
Message-ID: <4B9772EB.9010909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64370 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751987Ab0CJKV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Mar 2010 05:21:28 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

   When using command "service nfslock stop" and "service nfsklock start"
to restart the nfslock service at RHEL with kernel 2.6.31, if start the service
after stop it more than the grace_period time, lock which lockd get before
cann't be reclaimed for the grace_period is timeout.

So, IMO, the lockd should get into grace_period when statd start not stop?

Some code at kernel: fs/lockd/svclock.c
 ....
 411         if (locks_in_grace() && !reclaim) {
 412                 ret = nlm_lck_denied_grace_period;
 413                 goto out;
 414         }
 415         if (reclaim && !locks_in_grace()) {
 416                 ret = nlm_lck_denied_grace_period;
 417                 goto out;
 418         }
 ....

I think it can implement it like that:
  1) When statd stop, it send a KILL signal to lockd,
     and lockd only release the lock, but don't get into grace_period.
  2) When statd start, it send one some other signal to lockd,
     and lockd only get into grace_period. The lock will be reclaimed.

thanks,
Mi Jinlong

