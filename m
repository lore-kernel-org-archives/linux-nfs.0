Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab3KKLUt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 06:20:49 -0500
Message-ID: <1384168843.16759.50.camel@serendib>
Subject: Re: [PATCH] exportfs: modify can_test() to use LONG_MAX when
 appropriate
From: Harshula Jayasuriya <harshula@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        "J.Bruce Fields" <bfields@citi.umich.edu>
Date: Mon, 11 Nov 2013 22:20:43 +1100
In-Reply-To: <20131111185356.6e0fd0a9@notabene.brown>
References: <1376588800.17754.14.camel@serendib>
	 <20130815175258.GS17781@fieldses.org> <1384154434.16759.39.camel@serendib>
	 <20131111185356.6e0fd0a9@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-11-11 at 18:53 +1100, NeilBrown wrote:
> On Mon, 11 Nov 2013 18:20:34 +1100 Harshula Jayasuriya <harshula@redhat.com>
> wrote:
> 
> > This patch is the nfs-utils patch corresponding to the kernel patch 
> > commit 2f74f972d4cc7d83408ea0c32d424edcb44887bf "sunrpc: prepare NFS 
> > for 2038": "The kernel sunrpc code needs to handle seconds since epoch 
> > greater than 2147483647. This means functions that parse time as an 
> > int need to handle it as time_t."
> > 
> > When appropriate exportfs should use LONG_MAX in can_test() instead of
> > INT_MAX.
> > 
> > kernel INT_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> > =================================================================
> > 
> > exportfs: /mnt/export does not support NFS export:
> > ------------------------------------------------------------
> >  # cat /proc/net/rpc/auth.unix.ip/content
> >  #class IP domain
> > ------------------------------------------------------------
> > 
> > + mount fail:
> > ------------------------------------------------------------
> >  # cat /proc/net/rpc/auth.unix.ip/content
> >  #class IP domain
> >  # expiry=2147483768 refcnt=2 flags=4
> >  # nfsd 192.168.1.6 -no-domain-
> > ------------------------------------------------------------
> > 
> > kernel LONG_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> > ==================================================================
> > 
> > "exportfs: /mnt/export does not support NFS export":
> > ------------------------------------------------------------
> >  # cat /proc/net/rpc/auth.unix.ip/content
> >  #class IP domain
> > ------------------------------------------------------------
> > 
> > + mount success:
> > ------------------------------------------------------------
> >  # cat /proc/net/rpc/auth.unix.ip/content
> >  #class IP domain
> >  # expiry=2147485448 refcnt=2 flags=1
> >  nfsd 192.168.1.6 *
> > ------------------------------------------------------------
> > 
> > kernel LONG_MAX + exportfs LONG_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> > ===================================================================
> > 
> > exportfs:
> > ------------------------------------------------------------
> >  # cat /proc/net/rpc/auth.unix.ip/content
> >  #class IP domain
> >  # expiry=9223372036854775807 refcnt=1 flags=1
> >  nfsd 0.0.0.0 -test-client-
> > ------------------------------------------------------------
> > 
> > + mount success:
> > ------------------------------------------------------------
> >  # cat /proc/net/rpc/auth.unix.ip/content
> >  #class IP domain
> >  # expiry=2147485448 refcnt=2 flags=1
> >  nfsd 192.168.1.6 *
> >  # expiry=9223372036854775807 refcnt=1 flags=1
> >  nfsd 0.0.0.0 -test-client-
> > ------------------------------------------------------------
> > 
> > Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> > ---
> >  utils/exportfs/exportfs.c | 20 ++++++++++++++++----
> >  1 file changed, 16 insertions(+), 4 deletions(-)
> > 
> > diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> > index da5fe21..bccbed5 100644
> > --- a/utils/exportfs/exportfs.c
> > +++ b/utils/exportfs/exportfs.c
> > @@ -27,6 +27,8 @@
> >  #include <netdb.h>
> >  #include <errno.h>
> >  #include <dirent.h>
> > +#include <limits.h>
> > +#include <time.h>
> >  
> >  #include "sockaddr.h"
> >  #include "misc.h"
> > @@ -406,17 +408,27 @@ unexportfs(char *arg, int verbose)
> >  
> >  static int can_test(void)
> >  {
> > +	char buf[1024];
> >  	int fd;
> >  	int n;
> > -	char *setup = "nfsd 0.0.0.0 2147483647 -test-client-\n";
> > +
> >  	fd = open("/proc/net/rpc/auth.unix.ip/channel", O_WRONLY);
> > -	if ( fd < 0) return 0;
> > -	n = write(fd, setup, strlen(setup));
> > +	if (fd < 0)
> > +		return 0;
> > +
> > +	if (time(NULL) > INT_MAX)
> > +		sprintf(buf, "nfsd 0.0.0.0 %ld -test-client-\n", LONG_MAX);
> > +	else
> > +		sprintf(buf, "nfsd 0.0.0.0 %d -test-client-\n", INT_MAX);
> 
> This generally makes sense, but I think the cut-off is a bit too fine.
> If time(NULL) is exactly INT_MAX, then this might not do what is required.
> How about
>    if (time(NULL) > INT_MAX - (24*3600))
> ??

Good point. Mount attempts seem to fail not because of when exportfs is
run, but when the first mount request is made.

Is 1 day the right amount of tolerance? Or should we just go for a much
larger tolerance, on the assumption that the running kernel will have
commit 2f74f972d4cc7d83408ea0c32d424edcb44887bf by then? :-)

cya,
#


> > +
> > +	n = write(fd, buf, strlen(buf));
> >  	close(fd);
> >  	if (n < 0)
> >  		return 0;
> > +
> >  	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
> > -	if ( fd < 0) return 0;
> > +	if (fd < 0)
> > +		return 0;
> >  	close(fd);
> >  	return 1;
> >  }

