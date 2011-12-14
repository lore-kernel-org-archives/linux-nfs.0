Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569Ab1LNPTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 10:19:36 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEFJaF2011346
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 10:19:36 -0500
Date: Wed, 14 Dec 2011 10:19:27 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] clstated: reattempt the pipe open if it fails on
 ENOENT
Message-ID: <20111214101927.551e3883@tlielax.poochiereds.net>
In-Reply-To: <4EE8BC10.3010005@RedHat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
	<1323871032-3191-3-git-send-email-jlayton@redhat.com>
	<4EE8BC10.3010005@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Dec 2011 10:09:04 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 12/14/2011 08:57 AM, Jeff Layton wrote:
> > Generally, we want this daemon started before nfsd starts. Deal with the
> > situation where the pipe hasn't shown up yet.
> This can be done with your systemd start up script. Plus I'm not sure its 
> a good idea to steal cpu cycles waiting for an event that may never happen...
> 

Presumably you just wouldn't start the daemon if you have no intent to
use it.

It does sleep 1s between each check, so the time is fairly minimal,
but I'm definitely open to doing this differently. What may be
reasonable is adding code to the daemon to check and see if the
v4recoverydir is present. If it is, then just exit. Otherwise, wait for
the pipe to show up.

> 
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  utils/clstated/clstated.c |   15 +++++++++++----
> >  1 files changed, 11 insertions(+), 4 deletions(-)
> > 
> > diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
> > index 93a2710..aab09a7 100644
> > --- a/utils/clstated/clstated.c
> > +++ b/utils/clstated/clstated.c
> > @@ -75,10 +75,17 @@ usage(char *progname)
> >  static int
> >  clstate_pipe_open(struct clstate_client *clnt)
> >  {
> > -	clnt->cl_fd = open(pipepath, O_RDWR, 0);
> > -	if (clnt->cl_fd < 0) {
> > -		xlog(L_ERROR, "%s: unable to open %s: %m", __func__, pipepath);
> > -		return clnt->cl_fd;
> > +	/* loop until the pipe is present or open fails for another reason */
> > +	for (;;) {
> > +		clnt->cl_fd = open(pipepath, O_RDWR, 0);
> > +		if (clnt->cl_fd >= 0) {
> > +			break;
> > +		} else if (errno != ENOENT) {
> > +			xlog(D_GENERAL, "%s: unable to open %s: %m", __func__,
> > +					pipepath);
> > +			return clnt->cl_fd;
> > +		}
> > +		sleep(1);
> >  	}
> >  
> >  	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, clstatecb, clnt);


-- 
Jeff Layton <jlayton@redhat.com>
