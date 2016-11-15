Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56050 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751512AbcKOQCD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 11:02:03 -0500
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to
 /run/rpcbind
To: NeilBrown <neilb@suse.com>
References: <877f8almcf.fsf@notabene.neil.brown.name>
 <669e90b0-6011-7b82-4e37-f1e3bf292026@RedHat.com>
 <87k2c5i71h.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <85b23fdd-8dd4-9614-88ef-9691c3cdba3b@RedHat.com>
Date: Tue, 15 Nov 2016 11:02:01 -0500
MIME-Version: 1.0
In-Reply-To: <87k2c5i71h.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/15/2016 01:36 AM, NeilBrown wrote:
> On Tue, Nov 15 2016, Steve Dickson wrote:
>
>> On 11/10/2016 10:36 PM, NeilBrown wrote:
>>> rpcbind can save state in a file to allow restart without forgetting
>>> about running services.
>>>
>>> The default location is currently "/tmp" which is an over-used
>>> directory that isn't really suitable for system files.
>>> The modern preferences would be a subdirectory of "/run", which can
>>> be selected with a ./configure option.  That subdirectory would still need
>>> to be created by something.
>>>
>>> It is trivial for rpcbind to create the directory itself, and harmless
>>> to try if it already exists, so:
>>> - add a "mkdir" when saving state data
>>> - change the default to /run/rpcbind (currently used by Debian)
>>> - remove the default settign in the code, just use the one
>>>   in configure.ac
>> I'm all for move the warmstart directory to /run but why don't we have systemd
>> create the directory via a  tmpfiles.d( config file... some like
>>
>> #Type Path      Mode UID GID Age Argument
>> D  /run/rpcbind 0700 rpc rpc - -
>>
>> The only thing I'm not sure about is how it would get installed...
>> I guess it would some type of Makefile.ac entry??
> Because not everyone uses systemd?
Yeah... I figured as much.
> Someone at SUSE recently moved the state directory to /run/rpcbind and
> used tmpfiles.d exactly as you describe to create /run/rpcbind.  Then
> found they needed to do something extra and different for dracut.  I
> haven't looked into why, but it is presumably because while dracut does
> use systemd, it doesn't use it quite the same way that normal system boot
> uses it.
I didn't have this problem when I move rpcbind in RHEL7 to use /run/rpcbind via tmpfiles.d
The biggest problem I had was migrating the warmstart files to the new place.
Having /run/rpcbind exist after boot made that much easier. 
> I've found this with configuring mdadm too.  I got the udev and systemd
> configuration just right, and then found that while dracut uses udev and
> systemd, I still need to add extra stuff to dracut.  And then there was
> another boot environment which used udev but not systemd, so it needed
> different tweaking.
>
> So I think we are less likely to run into strange problems if we just
> get rpcbind to create its own directory.  Certainly rely on systemd to
> do the things that systemd does best (like start the service), but don't
> rely on it to do things we can easily do ourselves.
Another potential problem is SElinux... Its never a fan of daemon creating things
on the fly... but I guess that is my problem 8-)

steved.
 
>
> Thanks,
> NeilBrown
>

