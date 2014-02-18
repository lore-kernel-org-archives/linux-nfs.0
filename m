Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:29387 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593AbaBRO3K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Feb 2014 09:29:10 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 0/2] nfs-utils: systemd units bug fixes and comments.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1392713329-17979-1-git-send-email-steved@redhat.com>
Date: Tue, 18 Feb 2014 09:29:04 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FB361B21-041C-484F-815E-E4A90C3DAE06@oracle.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2014, at 3:48 AM, Steve Dickson <SteveD@redhat.com> wrote:

> Bug Fixes:
> 
> The /proc/net/rpc/use-gss-proxy file can not be used
> as a start up trigger for rpc.svcsgssd since it always
> exists, with or without gss-proxy installed.
> 
> Adding the Wants= to the nfs server unit cause a systemd ordering 
> cycle which caused reboots to take forever.
> 
> Comment One:
> 
> Even though nfs-client does conditionally start the rpc.gssd 
> service when /etc/krb5.keytab exists (which good),

No, that's bad.  rpc.gssd has to run in cases where there is no /etc/krb5.ktab.  See

 http://www.spinics.net/lists/linux-nfs/msg41585.html

The existence of /etc/krb5.conf is a better choice.

> but that's 
> all it does. Meaning 'systemctl status' does not show that rpc.gssd 
> is running and 'systemctl restart' does not restart rpc.gssd 
> and 'systemctl stop' does not stop the daemon.
> 
> It just seems odd to me that we will be using one target unit 
> to enable a daemon then another service unit (rpc-gssd) to 
> control it. 
> 
> I thinking we should  have one service unit, when enabled, control 
> both the rpc.gssd and the rpc.svcgssd daemons. The start up trigger 
> for both daemons will be the existence of /etc/krb5.keytab and 
> rpc.svcgssd will only be started if the nfs server is 
> enabled (if that is possible).
> 
> Comment Two:
> 
> How about renaming the nfs-utils unit to nfs-services since a 
> 'systemctl restart' of the unit start all the server and client 
> daemons (even when the server is not enabled, which is probably a bug).
> 
> Since a 'systemctl restart nfs-utils' starts all the daemons shouldn't
> 'systemctl stop nfs-utils' bring them all down as well?
> 
> Another oddity, going a 'systemctl restart nfs-utils' causes v3 
> mounts to go stale... Meaning going a ls on a v3 mount point 
> after the restart errors out with ESTALE... Not sure why... 
> 
> Comment Three:
> 
> I'm not seeing how the nfs-utils_env.sh file, called by each unit, 
> is all that useful. The main reason is you can not tell which 
> unit its being called from so how do know what should be done? 
> I guess I'm just missing the concept on how and what it should 
> be used for.
> 
> Steve Dickson (2):
>  rpc-svcgssd.service: removed a the start up triggers
>  systemd: Removed the "ordering cycle" from nfs-server.service
> 
> systemd/nfs-server.service  | 2 --
> systemd/rpc-svcgssd.service | 1 -
> 2 files changed, 3 deletions(-)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




