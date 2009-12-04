From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Fri, 04 Dec 2009 17:24:58 -0500
Message-ID: <1259965498.2825.5.camel@localhost>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
	 <1259964091.22044.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41784 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047AbZLDWZp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Dec 2009 17:25:45 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB4MPoX3008087
	for <linux-nfs@vger.kernel.org>; Fri, 4 Dec 2009 14:25:52 -0800 (PST)
In-Reply-To: <1259964091.22044.3.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-04 at 17:01 -0500, Trond Myklebust wrote: 
> Those look good to me. I had to fix them up a bit in order to have them
> apply on top of the nfs-for-next branch, but nothing major.

I figured I might as well push them out immediately. They compile, and
they don't seem to have any adverse effects on the NFSv4 stuff.

You can find them as the nfs-for-next branch on
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

Cheers
  Trond
