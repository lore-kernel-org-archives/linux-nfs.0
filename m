Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46025 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755731AbaIWCLM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 22:11:12 -0400
Date: Mon, 22 Sep 2014 22:11:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923021110.GB1409@fieldses.org>
References: <1411413608-16462-2-git-send-email-steved@redhat.com>
 <20140922152603.75005941@willson.usersys.redhat.com>
 <54207BCD.70101@RedHat.com>
 <20140922204401.GI26763@fieldses.org>
 <5420911D.6080506@RedHat.com>
 <20140922223423.GA29932@fieldses.org>
 <5420B78D.6040704@RedHat.com>
 <20140922202655.5e308e58@willson.usersys.redhat.com>
 <20140923015549.GB32712@fieldses.org>
 <20140923120804.51dbcc2e@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140923120804.51dbcc2e@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 12:08:04PM +1000, NeilBrown wrote:
> On Mon, 22 Sep 2014 21:55:49 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> > So, something like this?  (Untested, no idea if I'm doing this right.)
> > 
> > --b.
> > 
> > diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-module.service
> > new file mode 100644
> > index 000000000000..252545b458fd
> > --- /dev/null
> > +++ b/systemd/auth-rpcgss-module.service
> > @@ -0,0 +1,15 @@
> > +# We want to start gss-proxy on kernels that support it and rpc.svcgssd
> > +# on those that don't.  Those services check for support by checking
> > +# for existence of the path /proc/net/rpc/use-gss-proxy.  Before they
> > +# can perform that check, they need this module loaded.  (Unless
> > +# rpcsec_gss is built directly into the kernel, in which case this unit
> > +# will fail.  But that's OK.)
> > +[Unit]
> > +Description=Kernel Module supporting RPCSEC_GSS
> > +Before=gssproxy.service rpc-svcgssd.service
> > +
> > +[Service]
> > +ExecStart=/sbin/modprobe -q auth_rpcgss
> 
> I think you need
>    Type=oneshot
> 
> else systemd won't wait for the modprobe to complete before running the other
> services.

Whoops, yes, thought I'd done that but I guess not.

> > +
> > +[Install]
> > +WantedBy=gssproxy.service rpc-svcgssd.service
> 
> I don't think you want an install section.  That means the service has to be
> explicitly enabled, which is a pain.
> I think nfs-server.service should Want= this.
> I also think 
> 
>   ConditionPathExists=/etc/krb5.keytab
> 
> would be appropriate.

OK.

--b.
