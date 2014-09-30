Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbaI3QLJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2014 12:11:09 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8UGB9Uc013838
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 12:11:09 -0400
Date: Tue, 30 Sep 2014 12:11:07 -0400
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Move the wants only to the auth unit.
Message-ID: <20140930121107.0b10abe9@willson.usersys.redhat.com>
In-Reply-To: <542AD247.3040701@RedHat.com>
References: <1412014923-26587-1-git-send-email-simo@redhat.com>
	<1412014923-26587-2-git-send-email-simo@redhat.com>
	<542AC6AA.1090702@RedHat.com>
	<20140930113115.72fc400c@willson.usersys.redhat.com>
	<542AD247.3040701@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 30 Sep 2014 11:54:47 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 09/30/2014 11:31 AM, Simo Sorce wrote:
> > On Tue, 30 Sep 2014 11:05:14 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >> On 09/29/2014 02:22 PM, Simo Sorce wrote:
> >>> This way either gssproxy or rpc.svcgssd are started only if the
> >>> auth module is requested, and it finds a keytab.
> >>> If the wants are in the main nfs-client or nfs-server unit files
> >>> then the two deamons are started unconditionally and would require
> >>> conditions which we can test once and for all in a single unit
> >>> file instead.
> >>>
> >>> Signed-off-by: Simo Sorce <simo@redhat.com>
> >>> ---
> >>>  systemd/auth-rpcgss-module.service | 3 ++-
> >>>  systemd/nfs-client.target          | 4 ++--
> >>>  systemd/nfs-server.service         | 1 -
> >>>  3 files changed, 4 insertions(+), 4 deletions(-)
> >>>
> >>> diff --git a/systemd/auth-rpcgss-module.service
> >>> b/systemd/auth-rpcgss-module.service index
> >>> 3fc2f4ac924f7e9d6e24969bb9a21d88a5c144fc..0355e13e009528632e97373332db9fa3acdfd1a9
> >>> 100644 --- a/systemd/auth-rpcgss-module.service +++
> >>> b/systemd/auth-rpcgss-module.service @@ -6,7 +6,8 @@
> >>>  # unit will fail.  But that's OK.)
> >>>  [Unit]
> >>>  Description=Kernel Module supporting RPCSEC_GSS
> >>> -Before=gssproxy.service rpc-svcgssd.service
> >>> +Before=gssproxy.service rpc-svcgssd.service rpc-gssd.service
> >> By moving these into this unit,it destroys client/server
> >> sync starts commit 12a95eda talks about... 
> > 
> > No it does not, this before is critical, the kernel module must be
> > loaded before the gss daemons are started.
> Understood.... but both the nfs-server.service and nfs-client.target
> units have a Wants=auth-rpcgss-module.service, is not clear unit
> will get started first... On one of my very fast booting machines
> this race caused ordering cycles in systemd... I think... at least
> when I ordered the server to start then the client the cycles
> went a way... but who knows... 

Both nfs-server and nfs-client unit files have After: <gss unit files>
so they are always after them (I fixed a missing gssproxy.service one
in the last patch)
And auth-rpcgss-module.service has Before: <gss unit files>

So the ordering is fixed as per my last patch commit message.

> > 
> >> Maybe we could put an After=nfs-server.service in nfs-client.target
> > 
> > Why would you load the auth modules *after* nfs client and servers
> > are started ?
> > I think this could cause race conditions at mount on boot if someone
> > wants to mount a filesystem with sec=krb5
> Again it has nothing to do the loading of the module... You are
> correct the they have to be loaded before the gss daemons are started.
> Its all about the ordering of the server and client units.

So what is the ordering you are concerned about ?
The way I understand it is
1. load module
----
2. start rpc.gssd AND (rpc-svcgssd.service OR gssproxy.service)
   order between these seem not important so they can start in parallel
----
3. nfs client AND/OR nfs server
I do not know if there needs to be any ordering between the 2 above, I
operated on the assumption they can start in parallel

I left any ancillary daemon (statd/imapd/etc...) as it were, but if you
can add the ordering here I can double check those are starting in the
right order too.

> > 
> >> to bring back that synchronization... because in the end
> >> we really really want the server to start first especially
> >> when gssproxy is involved and both units are enabled.
> > 
> > uh ?
> > no you really want to start the auth damoens first, if the server
> > starts first then a mount request from a client could race with
> > gssproxy starting up and poking the proc file to enable use of
> > gssproxy resulting in the auth module to permanently initialize to
> > use the old interface.
> My bad on this one... I was thinking about when the nfs-client.target 
> was not starting gssproxy... there was race with the server which
> caused both gssproxy and rpc.svcgssd to be started. Now that the 
> client is starting gssproxy, that race no longer exists...

ok.
please let me know if I wrongly understood the ordering requirements we
have.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
