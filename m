Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f182.google.com ([74.125.82.182]:63944 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaDQTL7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Apr 2014 15:11:59 -0400
Received: by mail-we0-f182.google.com with SMTP id p61so841668wes.13
        for <linux-nfs@vger.kernel.org>; Thu, 17 Apr 2014 12:11:58 -0700 (PDT)
Message-ID: <5350277C.20608@dev.mellanox.co.il>
Date: Thu, 17 Apr 2014 22:11:56 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>,
        "'Chuck Lever'" <chuck.lever@oracle.com>
CC: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com> <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com> <534EA06A.7090200@dev.mellanox.co.il> <FC61F219-ACA2-4CE8-BF02-1B8EE2464639@oracle.com> <534F7D5F.1090908@dev.mellanox.co.il> <A7E4B101-BAF0-480C-95AE-26BB845EE2C3@oracle.com> <003001cf5a4a$1e3f5320$5abdf960$@opengridcomputing.com>
In-Reply-To: <003001cf5a4a$1e3f5320$5abdf960$@opengridcomputing.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/17/2014 5:34 PM, Steve Wise wrote:

<SNIP>
> You could use a small array combined with a loop and a budget count.  So the code would
> grab, say, 4 at a time, and keep looping polling up to 4 until the CQ is empty or the
> desired budget is reached...

Bingo... couldn't agree more.

Poll Arrays are a nice optimization, but large arrays will just burden 
the stack (and might even make things worse in high workloads...)

Sagi.
