From: =?EUC-KR?B?yKu9xSBzaGluIGhvbmc=?= <hongshin@gmail.com>
Subject: a suspected bug in nfs_free_seqid()
Date: Thu, 15 Jan 2009 19:53:34 +0900
Message-ID: <2014bcab0901150253p6941a323g5809c98c21e31122@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:59086 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbZAOKxf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jan 2009 05:53:35 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1202108wfd.4
        for <linux-nfs@vger.kernel.org>; Thu, 15 Jan 2009 02:53:34 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. I found a suspected bug while I review nfs_free_seqid() in nfs4state.c

It seems that nfs_free_seqid() tried to use "test and test-set" idiom
(double checked locking)
but the second "test" is missed so that It may occur data race when
other thread makes
&seqid->list not empty before the thread executiong nfs_free_seqid()
holds spin_lock(&sequence->lock) after checking !list_empty(&seqid->list).

I do not have much background for nfs so that it might not be a real bug
so please review the code and let me know whether it is real one or not.
Thanks.

Sincerely,
Shin Hong
