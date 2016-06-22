Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:55570 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbcFVQTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 12:19:49 -0400
Subject: Re: [PATCH v2 03/12] NFS: Cache aggressively when file is open for writing
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1466600806.90993.2.camel@primarydata.com>
Date: Wed, 22 Jun 2016 12:19:39 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <876B0E16-DE4B-4448-8433-A00D92D296B0@linuxhacker.ru>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com> <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com> <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com> <43F206E4-FCA8-4ED3-A4FC-4150AB927026@linuxhacker.ru> <1466600806.90993.2.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 22, 2016, at 9:06 AM, Trond Myklebust wrote:

> Hi Oleg,
> 
> Thanks for testing!
> 
> On Tue, 2016-06-21 at 18:25 -0400, Oleg Drokin wrote:
>> This patch still crashes for me.
>> 
> 
> The 2 attached patches should hopefully fix these 2 issues and will be
> rolled into v3 together with a cleanup patch to remove the now-obsolete 
> function nfs_revalidate_mapping_protected().

Yes, these two seems to be solving the issues.

Thanks.

