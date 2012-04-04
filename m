Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:49166 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab2DDAVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2012 20:21:02 -0400
Received: by wejx9 with SMTP id x9so163993wej.19
        for <linux-nfs@vger.kernel.org>; Tue, 03 Apr 2012 17:21:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAJC9VbvRm49iW2jFUfVqw4k20hPbLfrUr_Wm=pHLmD_23WJew@mail.gmail.com>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
 <CAOdHTRB5tfXvdEprnUpfswdr7Afq-cOvsqj2VicLipKc2sOK9w@mail.gmail.com> <CAAJC9VbvRm49iW2jFUfVqw4k20hPbLfrUr_Wm=pHLmD_23WJew@mail.gmail.com>
From: Lev Solomonov <solo@tonian.com>
Date: Wed, 4 Apr 2012 03:20:30 +0300
Message-ID: <CAOdHTRDSrXorJuV0Sipy1dLKrZhoRW+3aV=peBmOEX-u0a6DmQ@mail.gmail.com>
Subject: Re: About pNFS installation process.
To: Bruno Silva <bs@cin.ufpe.br>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sorry for the delay.

On Fri, Mar 23, 2012 at 19:21, Bruno Silva <bs@cin.ufpe.br> wrote:
> Fist of all, thanks for your replies.
>
> I still have a few questions:
>
> 1. What file system do you suggest? Why ext4 is not recommended?

i'm not aware of a single FS that will work perfectly out-of-the-box
with pNFS blocks layout on linux. in case of ext4/btrfs, there's tension
between the newer, advanced FS features and pNFS block layout underlying
FS requirements.

> 2. How know whether the pNFS is correctly set? Follows the blkmapd output:

IIRC neither client nor MDS nor DS emit blatantly bogus error messages,
so if you see any errors (e.g. 'failed' below) - that's a bad sign.

once you've cleared those, make sure that MDS exports pNFS, e.g.:
    grep pnfs /var/lib/nfs/etab
or similar shows your expected exports, and that client mounts those as
v4.1, e.g.:
    grep minorversion=1 /proc/mounts
or similar shows the expected mounts. then use the mounts on client
while sniffing the traffic, you'll want to see the file data move
around over iSCSI client<->DS rather than over NFS client<->MDS.

    <snip>
> *****    POINT 1    ******* I connected with four data servers using
> the command iscsiadm-m discovery-t-p SendTargets <IP DATE OF
> server>-l. But, note the output blkmapd "blkmapd: process_deviceinfo:
> 2 vols". I believe that should be listed four volumes, not two;

nope, the "2 vols" is just the single device info: simple+slice, and you
appear to have several of such devices. take a peek around GETDEVICEINFO
in RFC 5661 + 5663. regardless, DM barfed.

what export topology are you aiming for with those 4 volumes?

    <snip>
> Follows the output of command of "grep nfs /proc/self/mountstats"
>
> [bruno@fedora ~]$ grep nfs /proc/self/mountstats
> device sunrpc mounted on /var/lib/nfs/rpc_pipefs with fstype rpc_pipefs
> device 192.168.0.203:/ mounted on /home/bruno/shared with fstype nfs4
> statvers=1.0
>   nfsv4:  bm0=0xfdffbfff,bm1=0x40f9be3e,acl=0x3,sessions,pnfs=not configured
>   RPC iostats version: 1.0   p/v: 100003/4 (nfs)

the "pnfs=not configured" is bad news (no active pNFS layout driver),
you'll want that to say "pnfs=LAYOUT_BLOCK_VOLUME".

> My question is: How can i add other data servers in the structure and

did you manage to successfully export a single DS iSCSI LUN through MDS
over pNFS?

> how do I find out where the problem is?

DM is likely to have left something in /var/log/messages (or wherever)
on failed reloads. any 'device-mapper' entries there?

solo.
