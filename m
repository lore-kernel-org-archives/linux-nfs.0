From: Yuehai Xu <yuehaixu@gmail.com>
Subject: is nfsd sync or async?
Date: Mon, 9 Aug 2010 08:00:17 -0400
Message-ID: <AANLkTimU8OCKCaj0b5Ueg__c5DKSKGJWxoZUNK5xeyHk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yhxu-jgEIgUtgKzeHXe+LvDLADg@public.gmane.org, green.trace@gmail.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52299 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162Ab0HIMAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Aug 2010 08:00:19 -0400
Received: by wyb39 with SMTP id 39so9774820wyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Aug 2010 05:00:18 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

Suppose there is only one nfsd and two clients are sending random read
requests to this daemon. In this way, read ahead of the client should
not work since the requests are random. The requests between these two
clients should be async, while the requests from any one client of the
two should be sync. My question is about how will the nfsd handle
these requests, using sync or async mode in the kernel? Say, will nfsd
never handle the next request unless the previous request has been
served, without considering which clients the request belongs to? Or
nfsd just dispatch async requests to the lower level as soon as it
receives a request?

Any answer will be appreciate!

Yuehai
