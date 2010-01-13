From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] After nfs restart, locks can't be recovered which record by
 lockd before
Date: Wed, 13 Jan 2010 17:51:25 +0800
Message-ID: <4B4D979D.6090307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54562 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751259Ab0AMJvj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 04:51:39 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

When testing the nfs's lock at NFSv3, I get a problem.
So I want someone help me, thanks!

Test Process:
  Step1, ClientA get an exclusive lock success.
  Step2, Using command "service nfs restart" to restart server's nfs se=
rvice.
  Step3. ClientB get lock should fail, but success.

I think after step2 (nfs service restart), clientA's lock should be rec=
overed.
But like above, clientA's lock doesn=E2=80=99t be recovered.

When tracing the kernel, I find nfsd will cause lockd stop when it stop=
=2E
When lockd stop, all locks will be release which is record before at lo=
ckd.

When nfsd start, the lockd will start also, but the statd don't know wh=
at happened
 at kernel, so after that, locks will be lost.

Is it right when nfs stop, the lockd will stop too?=20
If it's right, should locks be recovered after lockd start?

thanks,
Mi Jinlong


