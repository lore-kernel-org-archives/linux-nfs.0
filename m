Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:42455 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757535Ab2HQKZQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2012 06:25:16 -0400
Received: by lbbgj3 with SMTP id gj3so2025916lbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2012 03:25:13 -0700 (PDT)
Message-ID: <502E1C38.2060104@compcenter.org>
Date: Fri, 17 Aug 2012 14:26:00 +0400
From: "Denis V. Nagorny" <dvnagorny@compcenter.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Randomly inaccessible files through NFS
References: <502B55A3.3030007@compcenter.org>
In-Reply-To: <502B55A3.3030007@compcenter.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

15.08.2012 11:54, Denis V. Nagorny пишет:
> Hello,
>
> Using Scientific Linux 6.1 (I think it's equal to RH EL 6.1) we met 
> the strange issue.  Several last months we have problem. After one or 
> two days of successful work, files on nfs server begins to be randomly 
> unacessible.
> I doesn't mean that files becames hidden or something like this. It 
> means that attempts to open some random files may be unsuccessful. 
> Usually restart of nfs server makes situation better but for several 
> days only. There are no any messages about errors in logs on server 
> and clients machines. Can anybody point me how can I try to understand 
> what happens at least. Sorry for my english.
>
> Denis.

Hello again,

I've made some additional experiments. It looks like nfs clients can be 
in one of two states: "quite stable" and "quite unstable". Clients are 
usually stable but after some heavy job with a lot of I/O with NFS 
server clients become "quite unstable" and fails even with single file 
operations with NFS server. In this state I can't unmount NFS shares and 
so on.  I've tried to analyse with wireshark and found that in unstable 
state there are a lot of NFS4ERR_EXPIRED answers from NFS server.  In 
one of experiments I've changed NICs in both machines involved - result 
the same. So I'm still looking for the ways to understand the problem.
Can anybody give me any advices?

Denis
