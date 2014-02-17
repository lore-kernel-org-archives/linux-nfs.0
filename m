Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f170.google.com ([209.85.214.170]:48946 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbaBQQq4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Feb 2014 11:46:56 -0500
Received: by mail-ob0-f170.google.com with SMTP id va2so17188054obc.15
        for <linux-nfs@vger.kernel.org>; Mon, 17 Feb 2014 08:46:56 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v3] NFSv4.1: new layout stateid can not be overwrite by one out of date
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1392620881-26561-1-git-send-email-shaobingqing@bwstor.com.cn>
Date: Mon, 17 Feb 2014 11:46:53 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-Id: <DEE24522-5DD2-4C42-9DD9-EC18F0FF05D8@primarydata.com>
References: <N> <1392620881-26561-1-git-send-email-shaobingqing@bwstor.com.cn>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 17, 2014, at 2:08, shaobingqing <shaobingqing@bwstor.com.cn> wrote:

> If initiate_file_draining returned NFS4ERR_DELAY, all the lsegs of
> a file might be released before the retrying cb_layout request arriving
> at the client. In this situation,the list lo->plh_segs is empty, 
> layoutget request of the file will use open stateid to obtain a new 
> layout stateid. And if the retrying cb_layout request arrived at the 
> client after the layoutget reply, new layout stateid would be overwrite 
> by one out of date.

I have very serious doubts about adding layout state to represent what the server is _trying_ to do. What if the server decides not to retry the recall? What if it reboots?

Let’s start with looking at the motivations: Have you ever run into the above problem in practice? If so, what was the effect on overall performance?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

