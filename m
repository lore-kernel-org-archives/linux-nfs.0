Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:62193 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaBYBog convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Feb 2014 20:44:36 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so2648152pdj.12
        for <linux-nfs@vger.kernel.org>; Mon, 24 Feb 2014 17:44:36 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid needing to write to /proc
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140225123701.08c59745@notabene.brown>
Date: Mon, 24 Feb 2014 17:44:30 -0800
Cc: Dickson Steve <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6C00269A-B840-4835-B277-CBCA9EE69AA8@primarydata.com>
References: <20140220063616.6548.42556.stgit@notabene.brown> <33021BB9-598C-4A65-B386-BE230E91894F@primarydata.com> <20140225123701.08c59745@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 24, 2014, at 17:37, NeilBrown <neilb@suse.de> wrote:

> On Thu, 20 Feb 2014 08:11:47 -0500 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On Feb 20, 2014, at 1:36, Neil Brown <neilb@suse.de> wrote:
>> 
>>> There are a number of NFS-related setting that currently must be set
>>> by writing to various files under /proc.
>>> This is a bit clumsy, particularly for systemd unit files.
>>> 
>>> So this series adds options to a number of commands where relevant.
>>> 
>>> The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortable with.
>>> The third (nlm grace time) I think is probably right but if someone can argue
>>> an alternate approach I'm unlikely to resist.
>>> The fourth is .... uhm.  You better look yourself.
>>> 
>>> Part of me thinks that nlm port numbers should be set in /etc/sysctl.conf (or sysctl.d)
>>> and /etc/modprobe.d should have something like
>>> 
>>> install lockd  sysctl -p /etc/sysctl.d/lockd
>>> 
>>> but last time I tried that it broke "modprobe --show-depends".
>>> Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sysctl.d/lockd
>>> 
>>> Thoughts?
>> 
>> Why not just do most of this at module load time with something like "modprobe lockd lockd.nlm_grace_period=<nsecs> lockd.nlm_tcpport=<portnr> …”?
>> Better yet, add/edit appropriate entries in /etc/modprobe.conf.d at system setup time.
>> 
> 
> Adding entries to /etc/modprobe.conf.d doesn't help if nfs is compiled in to
> the base kernel.
> Conversely, adding entries to /etc/sysctl.d doesn't help if nfs is a module.
> You could conceivable do both (for those few values that are available both
> as module parameters and sysctl settings) but that is clumsy and error prone.
> 

All the NFS sysctl settings now have module parameter equivalents.
Note that systemd can also override using the /sys/module interface, but the problem with both sysctl and /sys/module is that they get set _after_ the module has been loaded, and hence there is plenty of potential for races with mount requests.

> Your argument could equally well apply to setting the NFS versions that nfsd
> supports, but we have explicit command-line arguments for that.
> 
> Due to the highly ad-hoc collection of configuration settings and different
> ways to set them and rules for when they are set, I think it is best to have
> the settings imposed by code we control rather than requiring a similarly
> ad-hoc collection of additions to various configuration files in various
> directories.

See above. The races are the reason why I switched from sysctl to module params.

> Ultimately I would like all nfs-utils daemons to take settings out
> of /etc/sysconfig/nfs (either by reading it directly, or having systemd/bash
> load it into the environment, then the utils using getenv()), so that one
> file (which multiple distros already work with) can configure most of
> nfs-utils.  This is a step in that direction with (I think) immediate rewards.
> 
> Thanks,
> 
> NeilBrown

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

