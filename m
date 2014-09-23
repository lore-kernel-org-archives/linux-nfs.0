Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48987 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790AbaIWUZQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 16:25:16 -0400
Date: Tue, 23 Sep 2014 16:25:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923202514.GO29932@fieldses.org>
References: <20140922204401.GI26763@fieldses.org>
 <5420911D.6080506@RedHat.com>
 <20140922223423.GA29932@fieldses.org>
 <5420B78D.6040704@RedHat.com>
 <20140922202655.5e308e58@willson.usersys.redhat.com>
 <20140923015549.GB32712@fieldses.org>
 <20140923120804.51dbcc2e@notabene.brown>
 <20140923021110.GB1409@fieldses.org>
 <20140923192311.GI29932@fieldses.org>
 <5421D55B.8040403@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5421D55B.8040403@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 04:17:31PM -0400, Steve Dickson wrote:
> On 09/23/2014 03:23 PM, J. Bruce Fields wrote:
> > commit 3fab32b4bf96
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Mon Sep 22 21:43:59 2014 -0400
> > 
> >     systemd: manually insert auth_rpcgss module.
> >     
> >     We need to insert the auth_rpcgss module before starting rpc.svcgssd or
> >     gss-proxy, for two reasons:
> >     
> >     	- gss-proxy needs access to the /proc/net/rpc/use-gss-proxy file
> >     	  to set up communication with knfsd.
> >     	- the unit files need to able to test for the existance of the
> >     	  same path in order to decide whether the kernel supports
> >     	  gss-proxy or not.
> >     
> >     Currently we're using dependencies on proc-fs-nfsd.mount for this, but
> >     that works only because of the nfsd kernel module references some
> >     symbols in auth_rpcgss, which is an odd implementation detail we're
> >     likely to fix some day.
> >     
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-module.service
> > new file mode 100644
> > index 000000000000..3fc2f4ac924f
> > --- /dev/null
> > +++ b/systemd/auth-rpcgss-module.service
> > @@ -0,0 +1,14 @@
> > +# We want to start gss-proxy on kernels that support it and rpc.svcgssd
> > +# on those that don't.  Those services check for support by checking
> > +# for existence of the path /proc/net/rpc/use-gss-proxy.  Before they
> > +# can perform that check, they need this module loaded.  (Unless
> > +# rpcsec_gss support is built directly into the kernel, in which case this
> > +# unit will fail.  But that's OK.)
> > +[Unit]
> > +Description=Kernel Module supporting RPCSEC_GSS
> > +Before=gssproxy.service rpc-svcgssd.service
> > +ConditionPathExists=/etc/krb5.keytab
> > +
> > +[Service]
> > +Type=oneshot
> > +ExecStart=/sbin/modprobe -q auth_rpcgss
> > diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> > index f3c09e76a0f7..474f5e9ad74b 100644
> > --- a/systemd/nfs-client.target
> > +++ b/systemd/nfs-client.target
> > @@ -5,7 +5,7 @@ Wants=remote-fs-pre.target
> >  
> >  # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
> >  # start that on demand if needed.
> > -Wants=rpc-gssd.service rpc-svcgssd.service
> > +Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
> >  Wants=nfs-blkmap.service rpc-statd-notify.service
> >  Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
> >  
> > diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> > index 2fa7387e1cb9..fd213a3995de 100644
> > --- a/systemd/nfs-server.service
> > +++ b/systemd/nfs-server.service
> > @@ -3,6 +3,7 @@ Description=NFS server and services
> >  Requires= network.target proc-fs-nfsd.mount rpcbind.target
> >  Requires= nfs-mountd.service
> >  Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> > +Wants=auth-rpcgss-module.service
> >  Wants=rpc-statd-notify.service
> >  
> >  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
> > 
> I through this into my test world

Thanks!

> and one side effect of this patch
> is both rpc.gssd and rpc.svcgssd daemons are *always* started when 
> a key tab exists (/etc/krb5.keytab) and *all* the services (nfs-client,
> nfs-server, rpc-gssd, and rpc-svcgssd) are disabled, which is not 
> good... Those daemons don't need to be started when both sides 
> are disabled...  But the auth_rpcgss is loaded! ;-) 

Weird.  I can't see how this patch on its own would have any effect on
that.

--b.
