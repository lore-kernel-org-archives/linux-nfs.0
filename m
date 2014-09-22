Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57049 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754854AbaIVUoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 16:44:03 -0400
Date: Mon, 22 Sep 2014 16:44:01 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140922204401.GI26763@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
 <1411413608-16462-2-git-send-email-steved@redhat.com>
 <20140922152603.75005941@willson.usersys.redhat.com>
 <54207BCD.70101@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54207BCD.70101@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 22, 2014 at 03:43:09PM -0400, Steve Dickson wrote:
> 
> 
> On 09/22/2014 03:26 PM, Simo Sorce wrote:
> > On Mon, 22 Sep 2014 15:20:07 -0400
> > Steve Dickson <steved@redhat.com> wrote:
> > 
> >> Added the gssproxy.service to both the Wants= and
> >> Atfers= lines, before the rpc-svcgssd.service. There
> >> are  ConditionPathExists= lines in the rpc-svcgssd.service
> >> unit which will stop the rpc.svcgssd daemon from
> >> starting when the gssproxy daemon is already running.
> >>
> >> Signed-off-by: Steve Dickson <steved@redhat.com>
> >> ---
> >>  systemd/nfs-server.service | 5 +++--
> >>  1 file changed, 3 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> >> index 2fa7387..c740fa2 100644
> >> --- a/systemd/nfs-server.service
> >> +++ b/systemd/nfs-server.service
> >> @@ -2,12 +2,13 @@
> >>  Description=NFS server and services
> >>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
> >>  Requires= nfs-mountd.service
> >> -Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service
> >> rpc-svcgssd.service +Wants=rpc-statd.service nfs-idmapd.service 
> >> +Wants=rpc-gssd.service  
> >>  Wants=rpc-statd-notify.service
> >>  
> >>  After= network.target proc-fs-nfsd.mount rpcbind.target
> >> nfs-mountd.service After= nfs-idmapd.service rpc-statd.service
> >> -After= rpc-gssd.service rpc-svcgssd.service
> >> +After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
> >>  Before= rpc-statd-notify.service
> >>  
> >>  Wants=nfs-config.service
> > 
> > I think you really need to insure that the modules are loaded before
> > any of the server services are started, perhaps adding a unit file that
> > exec's modprobe and has "Before: gssproxy.service rpc-svcgssd.service"
> > in it ?
> I really don't think its needed... From my testing it appears 
> gssproxy is always being started and rpc.svcgssd is not... 

Huh.  Well rpc-svcgssd.service has var-lib-nfs-rpc_pipefs.mount as both
"Requires=" and "After=", so rpc-svcgssd.service will never run
without first running var-lib-nfs-rpc_pipefs.mount, which will load
sunrpc.  But I don't see where auth_rpcgss is getting loaded.  And I
don't see what ensures anything happening before gssproxy runs.

We want to make sure your testing's not just getting lucky on the
startup order.

> Plus, from my understanding...  loading module from a service 
> file is a big no no! People were having problems with
> way back when... 

Any pointers?  Google's not finding me anything.

--b.
