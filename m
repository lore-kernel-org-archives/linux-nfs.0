Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kawka.in.waw.pl ([178.63.212.103]:32903 "EHLO kawka.in.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815AbbCCTSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 14:18:09 -0500
Date: Tue, 3 Mar 2015 20:18:03 +0100
From: Zbigniew =?utf-8?Q?J=C4=99drzejewski-Szmek?= <zbyszek@in.waw.pl>
To: Andrei Borzenkov <arvidjaar@gmail.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH] systemd: Have rpc-statd-notify.service
 Require network.target
Message-ID: <20150303191803.GK3058@in.waw.pl>
References: <1425407803-5278-1-git-send-email-steved@redhat.com>
 <20150303220657.6ba6011b@opensuse.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150303220657.6ba6011b@opensuse.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2015 at 10:06:57PM +0300, Andrei Borzenkov wrote:
> В Tue,  3 Mar 2015 13:36:43 -0500
> Steve Dickson <steved@redhat.com> пишет:
> 
> > Its been reported that having the rpc-statd-notify service
> > depend on network.target instead network-online.target
> > decrease boot times as much as 10 seconds on some
> > installs
> > 
> 
> If it does not need network when strting, it should not depend on
> network at all. This will probably decrease boot time even more.
> 
> If it does need network, it should depend on network-online, this is
> correct.
Indeed. From the man page:
-m retry-time
    Specifies the length of time, in minutes, to continue retry‐
    ing  notifications to unresponsive hosts.  If this option is
    not specified, sm-notify attempts to send notifications  for
    15  minutes.   Specifying  a  value of 0 causes sm-notify to
    continue sending notifications to unresponsive  peers  until
    it is manually killed.

    Notifications  are retried if sending fails, the remote does
    not respond, the remote's NSM service is not registered,  or
    if  there  is  a  DNS  failure  which  prevents the remote's
    mon_name from being resolved to an address.

So rpc-statd-notify.service should be fine with being started before
the network is up at all.

Zbyszek

> 
> > Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1183293
> > 
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > Reported-by: Eric Work <work.eric@gmail.com>
> > ---
> >  systemd/rpc-statd-notify.service |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> > index a655445..b608a14 100644
> > --- a/systemd/rpc-statd-notify.service
> > +++ b/systemd/rpc-statd-notify.service
> > @@ -1,6 +1,6 @@
> >  [Unit]
> >  Description=Notify NFS peers of a restart
> > -Requires=network-online.target
> > +Requires=network.target
> >  After=network.target nss-lookup.target
> >  
> >  # if we run an nfs server, it needs to be running before we
> 
> _______________________________________________
> systemd-devel mailing list
> systemd-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/systemd-devel
