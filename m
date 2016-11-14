Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37290 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932343AbcKNT1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 14:27:08 -0500
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to
 /run/rpcbind
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
References: <877f8almcf.fsf@notabene.neil.brown.name>
 <20161111210034.GM21655@vapier.lan> <87polzj7sx.fsf@notabene.neil.brown.name>
 <20161114191234.GV21655@vapier.lan>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <8cbf8fc2-d358-37ca-75cf-c4e85e7aa3a4@RedHat.com>
Date: Mon, 14 Nov 2016 14:26:45 -0500
MIME-Version: 1.0
In-Reply-To: <20161114191234.GV21655@vapier.lan>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/14/2016 02:12 PM, Mike Frysinger wrote:
> On 14 Nov 2016 10:09, NeilBrown wrote:
>> On Sat, Nov 12 2016, Mike Frysinger wrote:
>>> On 11 Nov 2016 14:36, NeilBrown wrote:
>>>> rpcbind can save state in a file to allow restart without forgetting
>>>> about running services.
>>>>
>>>> The default location is currently "/tmp" which is an over-used
>>>> directory that isn't really suitable for system files.
>>>> The modern preferences would be a subdirectory of "/run", which can
>>>> be selected with a ./configure option.  That subdirectory would still need
>>>> to be created by something.
>>> the portable path is /var/cache instead of /run.  i don't think libtirpc
>>> should be configuring itself to assume Linux by default.
>> In principle I agree.  But is /var/cache really a good choice?
>> We don't want the state files to persist over a reboot, and I strongly
>> suspect that /var/cache is designed to do exactly that.
>>
>> Are there agree standards that are broader than Linux that we can look
>> to?
>> FHS defines /var/run (or even /run) but I suspect it is linux-only.
> /var/run should work across systems i believe.  at least BSD's support it.
In the Red Hat distos /var/run is a symbolic link to /run and the systemd
folks have asked us to use /run instead of /var/run

steved.

