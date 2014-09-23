Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47403 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785AbaIWPQW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 11:16:22 -0400
Date: Tue, 23 Sep 2014 11:16:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923151621.GB29932@fieldses.org>
References: <1411413608-16462-2-git-send-email-steved@redhat.com>
 <20140922152603.75005941@willson.usersys.redhat.com>
 <54207BCD.70101@RedHat.com>
 <20140922204401.GI26763@fieldses.org>
 <5420911D.6080506@RedHat.com>
 <20140922223423.GA29932@fieldses.org>
 <5420B78D.6040704@RedHat.com>
 <20140922202655.5e308e58@willson.usersys.redhat.com>
 <20140923015549.GB32712@fieldses.org>
 <54218C85.6040005@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54218C85.6040005@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 11:06:45AM -0400, Steve Dickson wrote:
> 
> 
> On 09/22/2014 09:55 PM, J. Bruce Fields wrote:
> > On Mon, Sep 22, 2014 at 08:26:55PM -0400, Simo Sorce wrote:
> >> No, starting before those service in itself achieves nothing.\
> >> I think what may cause the module to load maybe the fact
> >> gssproxy.service includes:
> >> Requires=proc-fs-nfsd.mount
> > 
> > I'd expect that to only load the nfsd module.
> > 
> > Hm, I think nfsd actually has a dependency on auth_rpcgss.  I wonder if
> > that's correct.  Maybe that's what's doing it.
> It is... In another thread I clearly showed that....

The dependency of nfsd on auth_rpcgss looks to me like an implementation
detail.  The client module doesn't have the same dependency.  We
definitely shouldn't depend on it, as the dependency could get removed
some day.

> So I really don't think another unit file is necessary...

I haven't seen an alternative yet.

--b.

> 
> steved.
>  
> > 
> >> But to be honest this was a hack to deal with broken nfs service files,
> >> gss-proxy should not require nfsd, the dependency should be the other
> >> way around, as gss-proxy can run on machines where there is no nfs
> >> service whatsoever, as it stand this is a bug in gssproxy.service and
> >> I'd like to fix it.
> > 
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
> > +
> > +[Install]
> > +WantedBy=gssproxy.service rpc-svcgssd.service
> > 
