From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Tue, 03 Mar 2009 12:04:17 +0200
Message-ID: <49AD00A1.3050606@panasas.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com> <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com> <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com> <1222445161.10150.4.camel@localhost> <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com> <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809282121t6953e068n62870810f1d0874@mail.gmail.com> <b66ddc900809282153yb873d8ayf82f2a61eca9cc18@mail.gmail.com> <20080929172630.GB23212@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: howard chen <howachen@gmail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:52617 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbZCCKEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 05:04:24 -0500
Received: by ewy25 with SMTP id 25so2261437ewy.37
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2009 02:04:21 -0800 (PST)
In-Reply-To: <20080929172630.GB23212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 29, 2008, 20:26 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Sep 29, 2008 at 12:53:16PM +0800, howard chen wrote:
>> Hello all,
>>
>> On Mon, Sep 29, 2008 at 12:21 PM, howard chen <howachen@gmail.com> wrote:
>>> Yes, tested, and same error... Also tried "no_root_squash"...
>>>
>>> Really have no idea what is going on...
>>>
>> Problem solved by adding the following line in fstab, according to
>> this site: http://www.linuxforums.org/forum/linux-networking/44779-nfs-permission-denied-error.html
> 
> Huh.  Surely mountd or knfsd could have given a more helpful error
> message, at least....

I agree.
I've just hit this problem again today (running Fedora 9).
(and I think http://bugzilla.redhat.com/show_bug.cgi?id=218994 might
be the same thing BTW)

rpc.mountd just prints
authenticated mount request from 192.168.0.140:669 for /usr0/export
even when invoked with --debug all.

However it denies access.  Here's tshark -V output:

Remote Procedure Call, Type:Call XID:0xee9360da
    Fragment header: Last fragment, 124 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0111 1100 = Fragment Length: 124
    XID: 0xee9360da (4002635994)
    Message Type: Call (0)
    RPC Version: 2
    Program: MOUNT (100005)
    Program Version: 3
    Procedure: MNT (1)
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 68
        Stamp: 0x004235f6
        Machine Name: pangw.bhalevy.com
            length: 17
            contents: pangw.bhalevy.com
            fill bytes: opaque data
        UID: 0
        GID: 0
        Auxiliary GIDs
            GID: 0
            GID: 1
            GID: 2
            GID: 3
            GID: 4
            GID: 6
            GID: 10
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Mount Service
    [Program Version: 3]
    [V3 Procedure: MNT (1)]
    Path: /usr0/export
        length: 12
        contents: /usr0/export

...
Remote Procedure Call, Type:Reply XID:0xee9360da
    Fragment header: Last fragment, 28 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0001 1100 = Fragment Length: 28
    XID: 0xee9360da (4002635994)
    Message Type: Reply (1)
    [Program: MOUNT (100005)]
    [Program Version: 3]
    [Procedure: MNT (1)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 3474]
    [Time from request: 0.000868000 seconds]
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
    Accept State: RPC executed successfully (0)
Mount Service
    [Program Version: 3]
    [V3 Procedure: MNT (1)]
    Status: ERR_ACCESS (13)

Running strace rpc.mountd -F --debug all shows:
...
open("/proc/fs/nfsd/filehandle", O_RDWR) = -1 ENOENT (No such file or directory)
open("/proc/fs/nfs/filehandle", O_RDWR) = -1 ENOENT (No such file or directory)


> 
>> nfsd /proc/fs/nfsd nfsd auto,defaults 0 0

doping this manually using
mount -t nfsd nfsd /proc/fs/nfsd
does the same trick

>>
>>
>> This is really funny as I never have this option in my other NFS servers....
>>
>> Anyone know the reason? Redhat's bug?
> 
> It looks like nfsd is supposed to be mounted on load of the nfsd module,
> by a line in /etc/modprobe.d/modprobe.conf.

Right.

# grep nfsd /etc/modprobe.d/modprobe.conf.dist
install nfsd /sbin/modprobe --first-time --ignore-install nfsd && { /bin/mount -t nfsd nfsd /proc/fs/nfsd > /dev/null 2>&1 || :; }
remove nfsd { /bin/umount /proc/fs/nfsd > /dev/null 2>&1 || :; } ; /sbin/modprobe -r --first-time --ignore-remove nfsd

> 
> (Maybe you built a new kernel with nfsd built-in instead of built as a
> module?)
> 
> But I thought nfs-utils was supposed to fall back on old behavior when
> the nfsd filesystem wasn't found.

Doesn't seem so.

Steve: any chance this bug is fixed anywhere?

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

