From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Re: kernel BUG at kernel/workqueue.c:291
Date: Tue, 03 Mar 2009 08:36:21 +0100
Message-ID: <49ACDDF5.8040506@aei.mpg.de>
References: <49A84376.6030800@aei.mpg.de>	<49ABBA44.1060302@aei.mpg.de> <20090302232643.7c7ca284.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:43384 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbZCCHgh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 02:36:37 -0500
In-Reply-To: <20090302232643.7c7ca284.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andrew,

Andrew Morton schrieb:
>> in the mean time 43 of our nodes were struck with this error. It seems
>> that the jobs of a certain user can trigger this bug, however I have no
>> clue how to really trigger it manually.
> 
> That's a lot of nodes.
Quite, at least some percentage of the whole system.
> 
> Let's cc the NFS developers, see if this rpciod crash is familiar to them?

Good idea, I should have done that myself - sorry

I think we were able to pinpoint at least one user's jobs to "generate"
this, but I need to talk to him, what access patterns are used via NFS here.

Systems are running Debian Etch,

dpkg -l | awk '/(nfs|portmap)/ {print $2 "\t\t" $3}'
libnfsidmap2            0.18-0
mountnfs                1.1.3-2
nfs-common              1.0.10-6+etch.1
nfs-kernel-server               1.0.10-6+etch.1
portmap         5-26


If you need more, please let me know! So far the machines are 'on hold',
i.e. we have not yet rebooted them to be able to find out a little bit
more. If you(anyone) think we can reboot them and put back into our
scheduling queue, please let me know, the users are waiting for more cycles.

Thanks a lot

Carsten
