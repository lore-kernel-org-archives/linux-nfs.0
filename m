Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:49286 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdFGMCX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jun 2017 08:02:23 -0400
Date: Wed, 7 Jun 2017 14:02:21 +0200
From: Lennart Poettering <mzxreary@0pointer.de>
To: Steve Dickson <SteveD@RedHat.com>
Cc: NeilBrown <neilb@suse.com>, systemd-devel@freedesktop.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option
 and systemd.
Message-ID: <20170607120221.GJ27006@gardel-login>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <87lgp4dbx7.fsf@notabene.neil.brown.name>
 <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 07.06.17 06:08, Steve Dickson (SteveD@RedHat.com) wrote:

> 
> 
> On 06/06/2017 05:49 PM, NeilBrown wrote:
> > On Tue, Jun 06 2017, Steve Dickson wrote:
> > 
> >> Hello,
> >>
> >> On 05/29/2017 06:19 PM, NeilBrown wrote:
> >>>
> >>> Systemd does not, and will not, support "bg" correctly.
> >>> It has other, better, ways to handle "background" mounting.
> >> The only problem with this is bg mounts still work at least
> >> up to 4.11 kernel... 
> > 
> > I don't think this is correct.
> > In the default configuration, "mount -t nfs -o bg ...."
> > runs for longer than 90 seconds, so systemd kill it.
> I must be missing something... it seems to be working for me
> 
> # mount -vvv -o bg rhel7srv:/home/tmp /mnt/tmp
> mount.nfs: trying text-based options 'bg,vers=4.1,addr=172.31.1.60,clientaddr=172.31.1.58'
> mount.nfs: mount(2): Connection refused
> mount.nfs: trying text-based options 'bg,addr=172.31.1.60'
> mount.nfs: prog 100003, trying vers=3, prot=6
> mount.nfs: trying 172.31.1.60 prog 100003 vers 3 prot TCP port 2049
> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
> mount.nfs: backgrounding "rhel7srv:/home/tmp"
> mount.nfs: mount options: "rw,bg"

We are talking about mounts done through /etc/fstab, i.e. the ones
systemd actually manages.

Lennart

-- 
Lennart Poettering, Red Hat
