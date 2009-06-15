From: "Roy M." <setesting001@gmail.com>
Subject: RPCNFSDCOUNT, still recommend 8 x CPU ?
Date: Tue, 16 Jun 2009 00:41:04 +0800
Message-ID: <beaf78240906150941i32126043lf9823c87bf45e9f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:36344 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbZFOQsN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 12:48:13 -0400
Received: by pzk17 with SMTP id 17so2061909pzk.33
        for <linux-nfs@vger.kernel.org>; Mon, 15 Jun 2009 09:48:16 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Is it common to use a larger number of NFS daemon (RPCNFSDCOUNT) then
the value recommended in faq, with today hardware?

i.e.

In the faq, it said try to set to 8 x CPU. So for a Quad Core SMP
system, it should be 64.

However, I see quite a few of people set RPCNFSDCOUNT=128.

http://www.google.com.hk/search?hl=zh-TW&q=RPCNFSDCOUNT%3D128&btnG=Google+%E6%90%9C%E5%B0%8B&meta=&aq=f&oq=

With today hardware (QC SMP, Dual Gigabit Enthernet, bundles of SAT
disks), do you think this value make sense?
