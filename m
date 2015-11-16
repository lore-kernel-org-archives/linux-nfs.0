Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbbKPU7g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2015 15:59:36 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 0979E8E22D
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2015 20:59:36 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-56-193.rdu2.redhat.com [10.10.56.193])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tAGKxZb0015714
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2015 15:59:35 -0500
Subject: Re: [PATCH 0/3] Improving rpc.gssd's debugging
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1446920050-5968-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <564A43B6.4070102@RedHat.com>
Date: Mon, 16 Nov 2015 15:59:34 -0500
MIME-Version: 1.0
In-Reply-To: <1446920050-5968-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/07/2015 01:14 PM, Steve Dickson wrote:
> Now that rpc.gssd is the critical path of every
> NFS mount, any favored mount, I thought I would
> take a crack at making the daemon a bit more 
> debuggable by making the logging more readable.
> 
> The first level of debugging (-v) will only log 
> errors and warnings that are not normally logged.
> I'm thinking this might be a good level to run
> at a customer's site.
> 
> I also thought about changing the majority of the 
> printerr(0) which always log to printerr(1)s. I 
> decided not to since I figured more info is 
> better.
> 
> Note, I didn't remove any of the messages, I just pushed
> them back to other debug levels. 
> 
> I trimmed down the second level of debugging (-vv) 
> by again moving them back to other levels. 
> 
> The third level (-vvv) is basically the same.
> 
> Using the fourth level (-vvvv) to enable all the logging
> that old level three did.
> 
> Thoughts/Comments... A waste of a good Saturday afternoon?? ;-) 
> 
> Steve Dickson (3):
>   gssd: reworked first level of debugging
>   gssd: log all fatal errors
>   gssd: reworked second level of debugging
All three patches committed... 

steved.
