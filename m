From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount command: fix config.h includes in util/mount
Date: Tue, 11 Mar 2008 13:13:28 -0400
Message-ID: <47D6BDB8.6020603@RedHat.com>
References: <20080311154734.31719.64271.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbYCKROK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2008 13:14:10 -0400
In-Reply-To: <20080311154734.31719.64271.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Recently #include directives for autoconf's config.h file were added in
> utils/mount/error.c and utils/mount/mount.c, but appropriate HAVE_CONFIG_H
> checks were not added at the same time.
> 
> In addition, several other .c files under utils/mount reference
> autoconf-generated HAVE_ macros, but don't appear to include config.h
> 
> Also, Heinz-Ado Arnolds <arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org> reports that this
> patch is needed to ensure START_STATD is properly defined in
> utils/mount/network.c.  Otherwise start_statd() is always a no-op, even if
> the configure script defines an appropriate statd start-up script.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Heinz-Ado Arnolds <arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org>
Committed...

steved.
