Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:7469 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218Ab3BVXun convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2013 18:50:43 -0500
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r1MNof5O006081
	for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2013 15:50:41 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Connectathon: upstream linux NFS client testing...
Date: Fri, 22 Feb 2013 23:50:39 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DCE82@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I've put up a kernel for testing the upstream linux NFS client here:

http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/cthon2013

It is based on the Linux 3.8 release, with the nfs-for-3.9-1 tag (that
was recently pushed upstream) and my 'bugfixes' branch merged in.

I plan to keep this branch up to date with any new client bugfixes for
the duration of the next week's Connectathon testing event.

Happy testing!

  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
