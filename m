Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754077AbaBSQDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Feb 2014 11:03:42 -0500
Subject: Re: [PATCH 1/2] rpc-svcgssd.service: removed a the start up
 triggers
From: Simo Sorce <simo@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <20140219141712.54cb31a7@notabene.brown>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
	 <1392713329-17979-2-git-send-email-steved@redhat.com>
	 <20140219141712.54cb31a7@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Feb 2014 11:03:36 -0500
Message-ID: <1392825816.22754.158.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-02-19 at 14:17 +1100, NeilBrown wrote:
> On Tue, 18 Feb 2014 03:48:48 -0500 Steve Dickson <steved@redhat.com> wrote:
> 
> > The file /proc/net/rpc/use-gss-proxy exists whether
> > gss-proxy is or is not installed. So is existence
> > can not be used as start up trigger.
> > 
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > ---
> >  systemd/rpc-svcgssd.service | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> > index 6bd4588..8e10b98 100644
> > --- a/systemd/rpc-svcgssd.service
> > +++ b/systemd/rpc-svcgssd.service
> > @@ -7,7 +7,6 @@ PartOf=nfs-utils.service
> >  
> >  After=gssproxy.service
> >  ConditionPathExists=|!@localstatedir@/run/gssproxy.pid
> > -ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
> >  ConditionPathExists=/etc/krb5.keytab
> >  
> >  [Service]
> 
> This is testing for non-existence, not existence.
> 
> We need rpc-svcgssd unless gssproxy can perform that task for us, in which
> case we don't want rpc-svcgssd.
> 
> gssproxy can only perform the task for us if:
>  1/ it is running (hence the test on the pid file)

could be stale

>  2/ the kernel knows how to talk to it (hence the test on use-gss-proxy)

use-gss-proxy is always available whether gss-proxy is being used or not
as it is the interface used by gss-proxy to tell the kernel it is in
use.

> With you version, if gssproxy were running on a kernel which did not include
> support for nfsd talking to gssproxy, then rpc-svcgssd would fail to start,
> which isn't what we want.

True the right way to handle this would probably be to
make /proc/net/rpc/use-gss-proxy readable and start rpc.svcgssd if the
value is 0 ?

> This may be an unusual configuration but unless it is an impossible
> configuration I would rather the code remained as it was.
> (This should work on *all* distros, not just sane distros).

I agree with the sentiment.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

