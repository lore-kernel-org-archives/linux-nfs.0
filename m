Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36750 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751190AbdFGQIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 12:08:02 -0400
Date: Wed, 7 Jun 2017 12:08:01 -0400
To: Steve Dickson <SteveD@RedHat.com>
Cc: Lennart Poettering <mzxreary@0pointer.de>,
        NeilBrown <neilb@suse.com>, systemd-devel@freedesktop.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option
 and systemd.
Message-ID: <20170607160801.GD26995@fieldses.org>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <20170607081257.GH27006@gardel-login>
 <5132dc9e-42a4-feab-2ee8-fcecf1a1cf1f@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5132dc9e-42a4-feab-2ee8-fcecf1a1cf1f@RedHat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 07, 2017 at 06:04:12AM -0400, Steve Dickson wrote:
> 
> 
> On 06/07/2017 04:12 AM, Lennart Poettering wrote:
> > On Tue, 06.06.17 14:07, Steve Dickson (SteveD@RedHat.com) wrote:
> > 
> >> Hello,
> >>
> >> On 05/29/2017 06:19 PM, NeilBrown wrote:
> >>>
> >>> Systemd does not, and will not, support "bg" correctly.
> >>> It has other, better, ways to handle "background" mounting.
> >> The only problem with this is bg mounts still work at least
> >> up to 4.11 kernel... 
> >>
> >> It appears there is a problem with a 4.12 kernel. The mount no 
> >> longer errors out with ECONNREFUSED it just hangs in the 
> >> kernel trying forever... It sounds like a bug to me but 
> >> maybe that change was intentional.. Anna?? Trond???
> >>
> >> So I'm a bit hesitant to commit this since not accurate, yet.
> >>
> >> Finally, the whole idea of systemd randomly/silently 
> >> strip off mount options is crazy... IMHO... 
> >>
> >> Just because a concept that has been around for years
> >> does not fix well in the systemd world it gets
> >> rip out??? IDK... but I think we can do better than that.
> > 
> > Well "bg" doesn't really work on systemd systems, and this was never
> > different, hence I think it's only fair to document that it is
> > incompatible with systemd. 
> I'm seeing it work just fine... 
> 
> /etc/fstab: nfssrv:/home/tmp /mnt/tmp nfs bg 0 0
> nfssrv is down 
> reboot client 
> login to client 
> # ps ax | grep mount
>   980 ?        Ss     0:00 /sbin/mount.nfs nfssrv:/home/tmp /mnt/tmp -o rw,bg

Right, but I think we also need to see a "systemctl status
remote-fs.target", or something, to verify whether that's the forked
background process or just the foreground process that's still hanging
up some part of the boot process (even though it's gotten far enough
along that you can log in--unless logins aren't permitted till remote
fs's are mounted, I don't know.)

--b.
