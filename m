Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5658 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754759Ab1G1U6H convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 16:58:07 -0400
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Gregory Magoon <gmagoon@MIT.EDU>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 28 Jul 2011 16:58:04 -0400
In-Reply-To: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311886684.27285.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-07-28 at 15:23 -0400, Gregory Magoon wrote: 
> Hi,
> I have been having issues when running MPICH2-1.4 on a NFSv4 filesystem (they
> both seem to work fine on their own). When I mount as NFS version 4, I get lots
> of NFS traffic on my internal network (seen when I run sudo iftop -i eth1) and
> the mpich2 tests time out or give i/o errors. However, when I mount the NFS as
> version 3, the MPICH2 tests seem to work without any major problems. Even
> though I can get this working by switching to NFSv3, I would like to get MPICH2
> working with NFSv4, if possible. Is there something in my NFS configuration (see
> below) that is not possible with NFSv4 or is this some sort of conflict between
> MPICH2-1.4 and NFSv4?
> 
> Thanks,
> Greg
> 
> 
> Here is the /etc/exports on the NFS server:
> /usr/local 192.168.2.0/24(async,fsid=1,ro,no_root_squash,no_subtree_check)
> /home 192.168.2.0/24(async,fsid=2,rw,no_root_squash,no_subtree_check)
> 
> Here are the NFS mounting details from "nfsstat -m":
> 
> NFSv4 (hangs and times out, with large quantity of NFS traffic):
>  /home from 192.168.2.11:/home/
>  Flags:
>  rw,relatime,vers=4,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,port=0,timeo=20,retrans=32,sec=sys,clientaddr=192.168.2.1,minorversion=0,local_lock=none,addr=192.168.2.11
> 

This is getting to be a FAQ...

2 second timeouts over TCP are just plain wrong: they will cause you to
continuously disconnect and reconnect (as 'netstat -t' is bound to show
you). Please don't muck with the default timeo=600.

There is also no reason to mess with rsize and wsize: allow the client
and server to autonegotiate.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

