From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS Client mounts hang when exported directory do not
 exist
Date: Fri, 11 Apr 2008 20:14:27 -0400
Message-ID: <47FFFEE3.3010302@RedHat.com>
References: <47FF7FCC.2050403@RedHat.com>	 <1207927210.3379.1.camel@localhost.localdomain>	 <47FF8D6A.9040902@RedHat.com> <1207938902.3379.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757103AbYDLAOo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 20:14:44 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m3C0Eiep025620
	for <linux-nfs@vger.kernel.org>; Fri, 11 Apr 2008 20:14:44 -0400
In-Reply-To: <1207938902.3379.7.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Paris wrote:
> On Fri, 2008-04-11 at 12:10 -0400, Steve Dickson wrote:
>>> Does this mean the EACCES can/will again become fatal in mount.nfs like
>>> it used to be?
>> EACCES is still a non-fatal error as it was... 
I guess I didn't look back far enough...

> 
> "non-fatal error as it was"?  Huh?  Back in the days of binary mount
> data it was fatal.  Try this on a new and old system.
Yes, I see...

> That may well have been your problem, but it doesn't change the fact the
> EACCES has been a fatal error in mount.nfs until just recently.  Why was
> it changed?  When is EACCES not fatal?
It appears the change came in with the text-based mount.nfs changes

commit 4ce9ddfb03de06e90fb4cf0eb5767cb0e3a98905
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Oct 10 15:06:39 2007 -0400

    text-based mount.nfs: sort between permanent and temporary errors

and I'm not sure why EACCES was deemed a non fatal error, but I'm
beginning to agree with you... EACCES probably should be fatal...
But thats something easily fixed in nfs-utils...

steved.
