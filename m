Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057AbaBRIsy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 03:48:54 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1I8mr4u017907
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 03:48:54 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-63-232.rdu2.redhat.com [10.10.63.232])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s1I8mpqQ022496
	for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 03:48:52 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] nfs-utils: systemd units bug fixes and comments.
Date: Tue, 18 Feb 2014 03:48:47 -0500
Message-Id: <1392713329-17979-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bug Fixes:

The /proc/net/rpc/use-gss-proxy file can not be used
as a start up trigger for rpc.svcsgssd since it always
exists, with or without gss-proxy installed.

Adding the Wants= to the nfs server unit cause a systemd ordering 
cycle which caused reboots to take forever.

Comment One:

Even though nfs-client does conditionally start the rpc.gssd 
service when /etc/krb5.keytab exists (which good), but that's 
all it does. Meaning 'systemctl status' does not show that rpc.gssd 
is running and 'systemctl restart' does not restart rpc.gssd 
and 'systemctl stop' does not stop the daemon.

It just seems odd to me that we will be using one target unit 
to enable a daemon then another service unit (rpc-gssd) to 
control it. 

I thinking we should  have one service unit, when enabled, control 
both the rpc.gssd and the rpc.svcgssd daemons. The start up trigger 
for both daemons will be the existence of /etc/krb5.keytab and 
rpc.svcgssd will only be started if the nfs server is 
enabled (if that is possible).

Comment Two:

How about renaming the nfs-utils unit to nfs-services since a 
'systemctl restart' of the unit start all the server and client 
daemons (even when the server is not enabled, which is probably a bug).

Since a 'systemctl restart nfs-utils' starts all the daemons shouldn't
'systemctl stop nfs-utils' bring them all down as well?

Another oddity, going a 'systemctl restart nfs-utils' causes v3 
mounts to go stale... Meaning going a ls on a v3 mount point 
after the restart errors out with ESTALE... Not sure why... 

Comment Three:

I'm not seeing how the nfs-utils_env.sh file, called by each unit, 
is all that useful. The main reason is you can not tell which 
unit its being called from so how do know what should be done? 
I guess I'm just missing the concept on how and what it should 
be used for.

Steve Dickson (2):
  rpc-svcgssd.service: removed a the start up triggers
  systemd: Removed the "ordering cycle" from nfs-server.service

 systemd/nfs-server.service  | 2 --
 systemd/rpc-svcgssd.service | 1 -
 2 files changed, 3 deletions(-)

-- 
1.8.5.3

