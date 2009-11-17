From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] After server stop nfslock service, client still can get lock
 success
Date: Tue, 17 Nov 2009 17:47:15 +0800
Message-ID: <4B027123.4060100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51769 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753442AbZKQJpw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Nov 2009 04:45:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing NLM, i find a bug.
After server stop nfslock service, client still can get lock success

Test process:

  Step1: client open nfs file.
  Step2: client using fcntl to get lock.
  Step3: client using fcntl to release lock.
  Step4: service stop it's nfslock service.
  Step5: client using fcntl to get lock again.

At step5, client should get lock fail, but it's success.

Reason:
  When server stop nfslock service, client's host struct not be
  unmonitor at server. When client get lock again, the client's
  host struct will be reuse but don't monitor again. 
  So that, at step5 client can get lock success.

Question:
  1. Should unmonitor the client's host struct at server 
     when server stop nfslock service ?

  2. Whether let rpc.statd tell kernel it's status(when start and stop)
     by send a SM_NOTIFY ?

-- 
Regards
Mi Jinlong


