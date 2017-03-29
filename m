Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56480 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932664AbdC2XAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Mar 2017 19:00:06 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2796E6AAD3
        for <linux-nfs@vger.kernel.org>; Wed, 29 Mar 2017 23:00:00 +0000 (UTC)
Date: Wed, 29 Mar 2017 18:59:59 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] systemd: add generators for the rpc_pipefs
 mountpoint
Message-ID: <20170329225959.a5okdablgaanr64z@tonberry.usersys.redhat.com>
References: <20170328133703.19325-1-smayhew@redhat.com>
 <2aace10d-1b9b-b8e8-4f85-caf31f5f51bf@RedHat.com>
 <20170329180207.xkcxepra442j6vv6@tonberry.usersys.redhat.com>
 <6a24bdf2-d94b-1a7d-5e2e-ceeefea3cc72@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6a24bdf2-d94b-1a7d-5e2e-ceeefea3cc72@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 29 Mar 2017, Steve Dickson wrote:

> 
> 
> On 03/29/2017 02:02 PM, Scott Mayhew wrote:
> > On Wed, 29 Mar 2017, Steve Dickson wrote:
> > 
> >> Hello,
> >>
> >> On 03/28/2017 09:37 AM, Scott Mayhew wrote:
> >>> The nfs.conf and idmapd.conf files both have config options for the
> >>> pipefs mountpoint.  Currently, changing these from the defaults also
> >>> requires manually overriding the systemd unit files that are hard-coded
> >>> to mount the filesystem on /var/lib/nfs/rpc_pipefs.
> >> The Pipefs-Directory config variable is not documented in either
> >> idmapd.conf(5) or rpc.idmapd(8) or nfsidmap(5) so the only way
> >> to know about it as to read the code. I would not call that
> >> a supported interface and can easily be removed. IMHO.
> >> The same thing goes for the Cache-Expiration variable. 
> > 
> > So you're saying to document the Pipefs-Directory and Cache-Expiration
> > variables, not remove them... right?  I think they should be documented
> > in idmapd.conf(5) since the other pages both refer to idmapd.conf(5).
> I'm saying since they are not documented interfaces so we can
> move them out of idmapd.conf and into nfs.conf

But what is gained by doing that, really?  And "not documented" is not
quite the same thing as "unknown".  The RHEL 4 idmapd.conf used to even
include the Pipefs-Directory parameter, and I see references to it in
both Red Hat bugzillas and knowledge articles.

> >>
> >>>
> >>> This patch adds two generators to create drop-in config files to
> >>> override the dependencies for the systemd units that require the pipefs.
> >>> There are two because rpc.idmapd uses a separate configuration file.  If
> >>> idmapd's configurations are ever folded into the nfs.conf, then the
> >>> idmapd-rpc-pipefs-generator.c can be deleted and generate=1 can be
> >>> specified for idmapd in rpc-pipefs-generator.c.
> >> So I'm thinking we just read Pipefs-Directory out of 
> >> one spot that would be /etc/nfs.conf.
> > 
> > I agree but then rpc.idmapd and nfsidmap should be modified to read
> > /etc/nfs.conf instead of /etc/idmapd.conf by default, but that could be
> > confusing unless some of the section names and/or variable names from
> > /etc/idmapd.conf were changed up a bit.  That's quite a bit more than
> > I'm trying to accomplish here.
> I'm not saying move them all just move Pipefs-Directory into /etc/nfs.conf.
> Move them would be a pain and I agree, well beyond the cope of what you
> are trying to do here.
> 
> Yes, this means rpc.idmap would have to read out of two config files
> but in time that could change and looking at the code reading
> out of second config file does seems too difficult.
> 
I'm not saying it would be difficult reading those two settings out of a
different config file, I just don't see the need for it.

If you could specify the parameter once and only once, and have all the
programs that use that parameter use the same value, then I think maybe
it'd be a good idea, particularly for the pipefs filesystem where it
probably doesn't make sense to have multiple filesystems mounted on
different mountpoints...  but there's no support for 'global' settings
in nfs.conf (maybe that's a good idea though).

> 
> > 
> >> That way we would only 
> >> have to support one of these generators.
> > 
> > If your issue is that there are two generators then I can fold them into
> > single one... then if the idmapd.conf ever get folded into nfs.conf it's
> > simply a matter of deleting a few lines of code.  The only reason I made
> > two generators is becuase it made more sense to me that way.  I'm fine
> > either way.
> > 
> >>
> >> Also please document the Pipefs-Directory variable in both
> >> the nfs.conf man page and in the example nfs.conf file
> >> in the git tree. 
> > 
> > It's actually already documented in both, under the gssd section.
> Perfect... Just cut/past from the gssd section and add a 
> idmapd section to the examples in nfs.conf showing the
> default value.
> 
> > 
> >>
> >>>
> >>> This patch also adds a unit file to mount the pipefs on /run/rpc_pipefs,
> >>> since that is the most logical alternate location for the pipefs
> >>> filesystem.  Users wanting to use some other location besides
> >>> /var/lib/nfs/rpc_pipefs or /run/rpc_pipefs would have to create their
> >>> own systemd mount unit file, but the generators would take care of the
> >>> rest.
> >> I'm not sure I understand why this new unit file, run-rpc_pipefs.mount,
> >> is needed, especially since it is not being install (aka no updates
> >> to the Makefile.am files).
> > 
> > I forgot to update the Makefile.am by mistake.  I definitely want the
> > new unit file.  The idea is to give users a choice between
> > /var/lib/nfs/rpc_pipes and /run/rpc_pipefs without requiring them to go
> > manually messing around with systemd configs.
> Hmm... Why would users care and would a user do the switch via 
> a systemd command?

Most users probably don't care.  But the pacemaker cluster resource
agents do a bind mount over top of /var/lib/nfs.  In order to do that,
they unmount the pipefs, do the bind mount, and then remount the pipefs.
If unmounting the pipefs fails then the cluster has a tendency to fall
apart.  By moving the pipefs out of /var/lib/nfs then that's one less
thing to worry about.

The way the switch is done is edit the nfs.conf and idmapd.conf and then
either reboot, or do a 'systemctl daemon-reload' and then restart idmapd
and gssd.

> Also who is going to create that directory?

systemd creates the directory automatically.
> 
> The point of all this is I don't think we needed two generator.
> I would rather make changes to where (undocumented) config
> knobs are read to avoid the second generator.
 
I've already boiled it down to one generator.  Does that make a
difference?

-Scott
> 
> steved.
