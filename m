Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751329AbdGVQZl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 22 Jul 2017 12:25:41 -0400
Date: Sat, 22 Jul 2017 12:25:40 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v4] systemd: add instructions for disabling
 gssd to nfs.systemd.man
Message-ID: <20170722162540.aonaowrupf555trn@tonberry.usersys.redhat.com>
References: <20170720202422.14153-1-smayhew@redhat.com>
 <87a83wyi00.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87a83wyi00.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 22 Jul 2017, NeilBrown wrote:

> On Thu, Jul 20 2017, Scott Mayhew wrote:
> 
> > We've had several users complain about gssd automatically starting.  Not
> > everyone who has a krb5.keytab want to use secure NFS; the instructions
> > for disabling gssd ought to be on the man page in addition to the README
> > (which may not even be included in a distro's nfs-utils package).
> >
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  systemd/nfs.systemd.man | 17 ++++++++++++++++-
> >  1 file changed, 16 insertions(+), 1 deletion(-)
> >
> > diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
> > index 01801eb..7675320 100644
> > --- a/systemd/nfs.systemd.man
> > +++ b/systemd/nfs.systemd.man
> > @@ -79,11 +79,26 @@ unit should be enabled.
> >  Several other units which might be considered to be optional, such as
> >  .I rpc-gssd.service
> >  are careful to only start if the required configuration file exists.
> > -.I rpc-gsdd.service
> > +.I rpc-gssd.service
> >  will not start if the
> >  .I krb5.keytab
> >  file does not exist (typically in
> >  .IR /etc ).
> > +.B rpc.gssd
> > +is assumed to be needed if the
> > +.I krb5.keytab
> > +file is present.  If a site needs this file present but does not want
> > +.B rpc.gssd
> > +running, it should create
> > +.B /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
> 
> A substantially simpler approach would be to recommend
> 
>   systemctl mask rpc-gssd.service

Thanks, Neil.  I had actually tried that a while back, but it doesn't seem
to work in RHEL.  It works fine for rpcbind, so I thought that maybe the
Condition clause in the unit file took precedence over masking or
something.  I see now that masking rpc-gssd works in Fedora, so I'll go
digging in systemd to see if there's a bug fix that might need to be
backported to RHEL.

Anyways, any objection to listing both methods in the man page?

-Scott
> 
> "mask" is also useful for disabling rpcbind if you use NFSv4 only and
> don't want the extra service.
> 
> NeilBrown
> 
> 
> > +containing
> > +.RS
> > +.nf
> > +[Unit]
> > +ConditionNull=false
> > +.fi
> > +.RE
> > +
> >  .SS Restarting NFS services
> >  Most NFS daemons can be restarted at any time.  They will reload any
> >  state that they need, and continue servicing requests.  This is rarely
> > -- 
> > 2.9.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


