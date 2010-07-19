From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Fix endtime issue
Date: Mon, 19 Jul 2010 10:50:19 -0400
Message-ID: <4C44662B.3050607@RedHat.com>
References: <4C2BE997.8090808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Doug Nazar <nazard.michi@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934628Ab0GSOuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 10:50:21 -0400
In-Reply-To: <4C2BE997.8090808@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2010 09:04 PM, Doug Nazar wrote:
>  After finally tracking down an issue with rpc.gssd crashing which had
> been bugging me on and off for months, ran into another issue.
> 
> Commit 4c5ff6d4 removed the setting of endtime for a few contexts by
> accident.
> 
> Now to figure out why I get stale handles on submounts.
Committed...

steved.
