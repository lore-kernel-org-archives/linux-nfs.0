Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51707 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637Ab2C1NC0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 09:02:26 -0400
Received: by yenl12 with SMTP id l12so634405yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 06:02:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332887744-4222-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
	<1332887744-4222-2-git-send-email-Trond.Myklebust@netapp.com>
Date: Wed, 28 Mar 2012 22:02:25 +0900
Message-ID: <CAKYAXd9HT=eiKCuiyBDVE0DDoMKNPYL+KTeA_vcCV6ZY+1WBSQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFSv4.1: Fix layoutcommit error handling
From: Namjae Jeon <linkinjeon@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/3/28 Trond Myklebust <Trond.Myklebust@netapp.com>:
> Firstly, task->tk_status will always return negative error values,
> so the current tests for 'NFS4ERR_DELEG_REVOKED' etc. are all being
> ignored.
> Secondly, clean up the code so that we only need to test
> task->tk_status once!
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Reviewed-by: Namjae Jeon <linkinjeon@gmail.com>
This patch makes good sense.
Thanks~
> Cc: stable@vger.kernel.org
> ---
