Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbbAKPYn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Jan 2015 10:24:43 -0500
Message-ID: <54B295B7.9070509@RedHat.com>
Date: Sun, 11 Jan 2015 10:24:39 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: A couple systemd questions
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Neil,

You being the architect of the systemd scribes ;-)  I have a 
couple questions. 

The nfs-server service brings both the rpc.mountd and rpc.idmapd 
daemons up when the service is started, but only 
brings rpc.mountd down when the service is stopped. 

I'm assuming that was done because the client was 
using  rpc.idmapd to do its id mapping, but that is no 
longer the case with some clients. They use the 
key rings via nfsidmap command to do the id mapping

So I'm thinking the nfs-server service should bring 
both daemons up and down when the server is started 
and stopped since the server is the only service using 
the rpc.idmapd.

My attempted at doing this is to change the 
nfs-idmap service to do the following:

[Unit]
Description=NFSv4 ID-name mapping service
Requires=var-lib-nfs-rpc_pipefs.mount
After=var-lib-nfs-rpc_pipefs.mount
After=network.target
PartOf=nfs-server.service
PartOf=nfs-utils.service

Wants=nfs-config.service
After=nfs-config.service

[Service]
EnvironmentFile=-/run/sysconfig/nfs-utils
Type=forking
ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS

Almost exactly what the  rpc-mountd service does. 

Now I thought the "PartOf=nfs-server.service" would cause
rpc.idmapd to come down when the server came down, but that 
does not seem to be the case... The only way I can get 
nfs-idmap service to come down is to explicitly stop it... 
What am I missing?

Secondly, in all of the services where rpcbind is needed you 
reference the rpcbind.target instead of the rpcbind.service. 
Why is that?

The reason I'm ask is,  I'm seeing a problem  where rpc.statd fails 
to start because nfs_svc_create() fails. Meaning it was unable to
either create UPD/TCP sockets or the registrations to rpcbind fails.

I'm thinking its the later due a race between rpcbind and statd 
starting. I've seen races like before in with systemd services... 

So I'm thinking that race would not exist if the rpc-statd service
would use rpcbind.service in the "Requires=" and "After=" 
statements instead of rpcbind.target. Right?? 

tia,

steved.
