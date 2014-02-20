Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23720 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbaBTOcR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Feb 2014 09:32:17 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid needing to write to /proc
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <33021BB9-598C-4A65-B386-BE230E91894F@primarydata.com>
Date: Thu, 20 Feb 2014 06:32:05 -0800
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <3327A99A-B627-47E2-AE75-449DE830C0EC@oracle.com>
References: <20140220063616.6548.42556.stgit@notabene.brown> <33021BB9-598C-4A65-B386-BE230E91894F@primarydata.com>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 20, 2014, at 5:11 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Feb 20, 2014, at 1:36, Neil Brown <neilb@suse.de> wrote:
> 
>> There are a number of NFS-related setting that currently must be set
>> by writing to various files under /proc.
>> This is a bit clumsy, particularly for systemd unit files.
>> 
>> So this series adds options to a number of commands where relevant.
>> 
>> The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortable with.
>> The third (nlm grace time) I think is probably right but if someone can argue
>> an alternate approach I'm unlikely to resist.
>> The fourth is .... uhm.  You better look yourself.
>> 
>> Part of me thinks that nlm port numbers should be set in /etc/sysctl.conf (or sysctl.d)
>> and /etc/modprobe.d should have something like
>> 
>> install lockd  sysctl -p /etc/sysctl.d/lockd
>> 
>> but last time I tried that it broke "modprobe --show-depends".
>> Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sysctl.d/lockd
>> 
>> Thoughts?
> 
> Why not just do most of this at module load time with something like "modprobe lockd lockd.nlm_grace_period=<nsecs> lockd.nlm_tcpport=<portnr> …”?
> Better yet, add/edit appropriate entries in /etc/modprobe.conf.d at system setup time.

If we’re setting configuration options in a file in /etc, maybe we’d be better off if these daemons each had their own .conf files.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



