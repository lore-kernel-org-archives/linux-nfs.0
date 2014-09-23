Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbaIWMqj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 08:46:39 -0400
Date: Tue, 23 Sep 2014 08:46:30 -0400
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923084630.10868ee8@willson.usersys.redhat.com>
In-Reply-To: <20140923015549.GB32712@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922152603.75005941@willson.usersys.redhat.com>
	<54207BCD.70101@RedHat.com>
	<20140922204401.GI26763@fieldses.org>
	<5420911D.6080506@RedHat.com>
	<20140922223423.GA29932@fieldses.org>
	<5420B78D.6040704@RedHat.com>
	<20140922202655.5e308e58@willson.usersys.redhat.com>
	<20140923015549.GB32712@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Sep 2014 21:55:49 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 22, 2014 at 08:26:55PM -0400, Simo Sorce wrote:
> > On Mon, 22 Sep 2014 19:58:05 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> > > 
> > > 
> > > On 09/22/2014 06:34 PM, J. Bruce Fields wrote:
> > > > On Mon, Sep 22, 2014 at 05:14:05PM -0400, Steve Dickson wrote:
> > > >>
> > > >>
> > > >> On 09/22/2014 04:44 PM, J. Bruce Fields wrote:
> > > >>> On Mon, Sep 22, 2014 at 03:43:09PM -0400, Steve Dickson wrote:
> > > >>>>
> > > >>>>
> > > >>>> On 09/22/2014 03:26 PM, Simo Sorce wrote:
> > > >>>>> On Mon, 22 Sep 2014 15:20:07 -0400
> > > >>>>> Steve Dickson <steved@redhat.com> wrote:
> > > >>>>>
> > > >>>>>> Added the gssproxy.service to both the Wants= and
> > > >>>>>> Atfers= lines, before the rpc-svcgssd.service. There
> > > >>>>>> are  ConditionPathExists= lines in the rpc-svcgssd.service
> > > >>>>>> unit which will stop the rpc.svcgssd daemon from
> > > >>>>>> starting when the gssproxy daemon is already running.
> > > >>>>>>
> > > >>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
> > > >>>>>> ---
> > > >>>>>>  systemd/nfs-server.service | 5 +++--
> > > >>>>>>  1 file changed, 3 insertions(+), 2 deletions(-)
> > > >>>>>>
> > > >>>>>> diff --git a/systemd/nfs-server.service
> > > >>>>>> b/systemd/nfs-server.service index 2fa7387..c740fa2 100644
> > > >>>>>> --- a/systemd/nfs-server.service
> > > >>>>>> +++ b/systemd/nfs-server.service
> > > >>>>>> @@ -2,12 +2,13 @@
> > > >>>>>>  Description=NFS server and services
> > > >>>>>>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
> > > >>>>>>  Requires= nfs-mountd.service
> > > >>>>>> -Wants=rpc-statd.service nfs-idmapd.service
> > > >>>>>> rpc-gssd.service rpc-svcgssd.service
> > > >>>>>> +Wants=rpc-statd.service nfs-idmapd.service
> > > >>>>>> +Wants=rpc-gssd.service Wants=rpc-statd-notify.service
> > > >>>>>>  
> > > >>>>>>  After= network.target proc-fs-nfsd.mount rpcbind.target
> > > >>>>>> nfs-mountd.service After= nfs-idmapd.service
> > > >>>>>> rpc-statd.service -After= rpc-gssd.service
> > > >>>>>> rpc-svcgssd.service +After= rpc-gssd.service
> > > >>>>>> gssproxy.service rpc-svcgssd.service Before=
> > > >>>>>> rpc-statd-notify.service 
> > > >>>>>>  Wants=nfs-config.service
> > > >>>>>
> > > >>>>> I think you really need to insure that the modules are
> > > >>>>> loaded before any of the server services are started,
> > > >>>>> perhaps adding a unit file that exec's modprobe and has
> > > >>>>> "Before: gssproxy.service rpc-svcgssd.service" in it ?
> > > >>>> I really don't think its needed... From my testing it
> > > >>>> appears gssproxy is always being started and rpc.svcgssd is
> > > >>>> not... 
> > > >>>
> > > >>> Huh.  Well rpc-svcgssd.service has
> > > >>> var-lib-nfs-rpc_pipefs.mount as both "Requires=" and
> > > >>> "After=", so rpc-svcgssd.service will never run without first
> > > >>> running var-lib-nfs-rpc_pipefs.mount, which will load
> > > >>> sunrpc.  But I don't see where auth_rpcgss is getting
> > > >>> loaded.  And I don't see what ensures anything happening
> > > >>> before gssproxy runs.
> > > >> It happens during the mount on the client and when the server
> > > >> is started. 
> > > >>
> > > >>>
> > > >>> We want to make sure your testing's not just getting lucky on
> > > >>> the startup order.
> > > >> The reason it working is because rpc.gssd is being started on
> > > >> the server these days for callbacks and the After= line in
> > > >> rpc-svcgssd.service is being executed before the
> > > >> ConditionPathExists which cause rpc.svcgssd not to start.
> > > > 
> > > > nfs-utils$ grep After systemd/rpc-svcgssd.service 
> > > > After=var-lib-nfs-rpc_pipefs.mount
> > > > After=gssproxy.service
> > > > After=nfs-config.service
> > > > 
> > > > There doesn't seem to be an After= line referring to rpc.gssd.
> > > No, why should there be? There is After= line referring to
> > > rpc.gssd in nfs-server.service
> > > 
> > > grep After systemd/nfs-server.service 
> > > After= network.target proc-fs-nfsd.mount rpcbind.target
> > > nfs-mountd.service After= nfs-idmapd.service rpc-statd.service
> > > After= rpc-gssd.service rpc-svcgssd.service
> > > After=nfs-config.service
> > > 
> > > So when the server starts,rpc.gssd will start and rpc.svcgssd will
> > > start if gssproxy is not enable and there is a key tab. 
> > 
> > They can start in parallel, there is nothing in that line that makes
> > one start before the other.
> > 
> > If you are relying on this you are relying on luck.
> > 
> > > >> So when gssproxy.service does it's "Before=nfs-secure.service
> > > >> nfs-secure-server.service" line everything is loaded before
> > > >> gssproxy start... 
> > > > 
> > > > That line only makes gss-proxy start before those other things.
> > > Right, which will load the sunrpc modules.
> > 
> > No, starting before those service in itself achieves nothing.\
> > I think what may cause the module to load maybe the fact
> > gssproxy.service includes:
> > Requires=proc-fs-nfsd.mount
> 
> I'd expect that to only load the nfsd module.
> 
> Hm, I think nfsd actually has a dependency on auth_rpcgss.  I wonder
> if that's correct.  Maybe that's what's doing it.
> 
> > But to be honest this was a hack to deal with broken nfs service
> > files, gss-proxy should not require nfsd, the dependency should be
> > the other way around, as gss-proxy can run on machines where there
> > is no nfs service whatsoever, as it stand this is a bug in
> > gssproxy.service and I'd like to fix it.
> 
> So, something like this?  (Untested, no idea if I'm doing this right.)
> 
> --b.
> 
> diff --git a/systemd/auth-rpcgss-module.service
> b/systemd/auth-rpcgss-module.service new file mode 100644
> index 000000000000..252545b458fd
> --- /dev/null
> +++ b/systemd/auth-rpcgss-module.service
> @@ -0,0 +1,15 @@
> +# We want to start gss-proxy on kernels that support it and
> rpc.svcgssd +# on those that don't.  Those services check for support
> by checking +# for existence of the
> path /proc/net/rpc/use-gss-proxy.  Before they +# can perform that
> check, they need this module loaded.  (Unless +# rpcsec_gss is built
> directly into the kernel, in which case this unit +# will fail.  But
> that's OK.) +[Unit]
> +Description=Kernel Module supporting RPCSEC_GSS
> +Before=gssproxy.service rpc-svcgssd.service
> +
> +[Service]
> +ExecStart=/sbin/modprobe -q auth_rpcgss
> +
> +[Install]
> +WantedBy=gssproxy.service rpc-svcgssd.service

Not sure about the last WantedBy, but this looks like what I had in
mind.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
