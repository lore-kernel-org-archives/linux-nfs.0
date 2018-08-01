Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa12.utexas.iphmx.com ([216.71.154.221]:29612 "EHLO
        esa12.utexas.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387511AbeHAUIY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 16:08:24 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Patrick Goetz <pgoetz@math.utexas.edu>
Subject: Restricting UDP access triggers systemd dependency issues
Message-ID: <63d1365d-d178-0d4b-1755-51418fe9a438@math.utexas.edu>
Date: Wed, 1 Aug 2018 13:11:46 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not sure if this list is an appropriate venue for this issue, but I 
can't think of where else to post.

On an Ubuntu 18.04 machine, with version 1:1.3.4-2.1ubuntu5 of the 
nfs-kernel-server package, I have the following strange issue.  The 
machine is joined to an AD domain, but the NFS service is completely 
independent from the directory service.

If I enable an rpc.nfsd environment variable restricting UPD access:

root@snakeskin:/lib/systemd/system# cat /run/sysconfig/nfs-utils
PIPEFS_MOUNTPOINT=/run/rpc_pipefs
RPCNFSDARGS=" 8"
RPCMOUNTDARGS="--manage-gids -N 2 -N 3 -U"
STATDARGS=""
RPCSVCGSSDARGS=""


The nfs-kernel-server service refuses to start. (I've experimented with 
all RPCMOUNTDARGS options, and the problem only occurs when -U is in the 
list.)

root@snakeskin:/lib/systemd/system# systemctl restart nfs-kernel-server
A dependency job for nfs-server.service failed. See 'journalctl -xe' for 
details.

The failed service is rpc.svcgssd:

================================================
Aug 01 12:58:21 snakeskin rpc.svcgssd[5635]: ERROR: GSS-API: error in 
gss_acquire_cred(): GSS_S_FAILURE (Unspecified GSS failure.  Minor code 
may provide more information) - No key table entry found matching nfs/@
Aug 01 12:58:21 snakeskin rpc.svcgssd[5635]: unable to obtain root 
(machine) credentials
Aug 01 12:58:21 snakeskin rpc.svcgssd[5635]: do you have a keytab entry 
for nfs/<your.host>@<YOUR.REALM> in /etc/krb5.keytab?
Aug 01 12:58:21 snakeskin systemd[1]: rpc-svcgssd.service: Control 
process exited, code=exited status=1
Aug 01 12:58:21 snakeskin systemd[1]: rpc-svcgssd.service: Failed with 
result 'exit-code'.
Aug 01 12:58:21 snakeskin systemd[1]: Failed to start RPC security 
service for NFS server.
-- Subject: Unit rpc-svcgssd.service has failed
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
-- 
-- Unit rpc-svcgssd.service has failed.
=====================================================

As indicated in the /etc/default/nfs-kernel-server file, this service 
shouldn't even be needed unless kerberos is managing exports:

# Do you want to start the svcgssd daemon? It is only required for Kerberos
# exports. Valid alternatives are "yes" and "no"; the default is "no".
NEED_SVCGSSD=""

# Options for rpc.svcgssd.
RPCSVCGSSDOPTS=""


However, the "NEED_SVCGSSD" isn't processed by nfs-config.service, and 
setting it explicitly to "no" has no effect.  Also notice RPCSVCGSSDOPTS 
which is converted to RPCSVCGSSDARGS by the nfs-config.service script, 
/usr/lib/systemd/scripts/nfs-utils_env.sh:

   echo RPCSVCGSSDARGS=\"$RPCSVCGSSDOPTS\"

This isn't being picked up by the rpc-svcgssd service, which is looking 
for a differently named environment variable:

============================================================
root@snakeskin:/lib/systemd/system# cat rpc-svcgssd.service
[Unit]
Description=RPC security service for NFS server
DefaultDependencies=no
Requires=run-rpc_pipefs.mount
After=run-rpc_pipefs.mount local-fs.target
PartOf=nfs-server.service
PartOf=nfs-utils.service

ConditionPathExists=/etc/krb5.keytab

Wants=nfs-config.service
After=nfs-config.service

[Service]
EnvironmentFile=-/run/sysconfig/nfs-utils
Type=forking
ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
============================================================

It seems that someone clearly messed up the service files, but is it the 
Debian package maintainer or upstream?

Also, is there a solution to not allowing UDP service while still 
allowing rpc.nfsd to run?

