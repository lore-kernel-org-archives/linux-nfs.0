From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] NFS Client mounts hang when exported directory do not
	exist
Date: Fri, 11 Apr 2008 14:35:02 -0400
Message-ID: <1207938902.3379.7.camel@localhost.localdomain>
References: <47FF7FCC.2050403@RedHat.com>
	 <1207927210.3379.1.camel@localhost.localdomain>
	 <47FF8D6A.9040902@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759196AbYDKSfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 14:35:10 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m3BIZA7s014544
	for <linux-nfs@vger.kernel.org>; Fri, 11 Apr 2008 14:35:10 -0400
In-Reply-To: <47FF8D6A.9040902-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-04-11 at 12:10 -0400, Steve Dickson wrote:
> 
> Eric Paris wrote:
> > On Fri, 2008-04-11 at 11:12 -0400, Steve Dickson wrote:
> >> This patch fixes a regression that was introduced by the string based mounts. 
> >>
> >> nfs_mount() statically returns -EACCES for every error returned
> >> by the remote mounted. This is incorrect because -EACCES is
> >> an non-fatal error to the mount.nfs command. This error causes
> >> mount.nfs to retry the mount even in the case when the exported
> >> directory does not exist. 
> >>
> >> This patch maps the errors returned by the remote mountd into
> >> valid errno values, exactly how it was done pre-string based 
> >> mounts. By returning the correct errno enables mount.nfs 
> >> to do the right thing.
> > 
> > Does this mean the EACCES can/will again become fatal in mount.nfs like
> > it used to be?
> EACCES is still a non-fatal error as it was... 

"non-fatal error as it was"?  Huh?  Back in the days of binary mount
data it was fatal.  Try this on a new and old system.

mount -o context=system_u:object_r:httpd_t:s0 server:/export /import

old system it was fatal and we died instantly with EACCES telling the
user it was a permissions problem.  New system I have to waste 2 minutes
and then get a message about it timing out.  It wasn't a timeout, it was
a permission failure.  Users are going to be looking down the wrong
path..

> The problem is the 
> kernel was should have been returning ENOENT, which is a fatal error,
> instead of EACCES.

That may well have been your problem, but it doesn't change the fact the
EACCES has been a fatal error in mount.nfs until just recently.  Why was
it changed?  When is EACCES not fatal?

-Eric

