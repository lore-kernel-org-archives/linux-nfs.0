Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751445AbdFHUeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 16:34:07 -0400
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and
 systemd.
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Lennart Poettering <mzxreary@0pointer.de>,
        NeilBrown <neilb@suse.com>, systemd-devel@freedesktop.org,
        linux-nfs@vger.kernel.org
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <20170607081257.GH27006@gardel-login>
 <5132dc9e-42a4-feab-2ee8-fcecf1a1cf1f@RedHat.com>
 <20170607160801.GD26995@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <93ae16cd-b5a6-35e8-d521-321901a21cc6@RedHat.com>
Date: Thu, 8 Jun 2017 16:34:05 -0400
MIME-Version: 1.0
In-Reply-To: <20170607160801.GD26995@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2017 12:08 PM, J. Bruce Fields wrote:
> On Wed, Jun 07, 2017 at 06:04:12AM -0400, Steve Dickson wrote:
>> # ps ax | grep mount
>>   980 ?        Ss     0:00 /sbin/mount.nfs nfssrv:/home/tmp /mnt/tmp -o rw,bg
> 
> Right, but I think we also need to see a "systemctl status
> remote-fs.target", or something, to verify whether that's the forked
> background process or just the foreground process that's still hanging
> up some part of the boot process (even though it's gotten far enough
> along that you can log in--unless logins aren't permitted till remote
> fs's are mounted, I don't know.)
It succeeds... 

# systemctl status remote-fs.target 
* remote-fs.target - Remote File Systems
   Loaded: loaded (/usr/lib/systemd/system/remote-fs.target; enabled; vendor preset: enabled)
   Active: active since Tue 2017-06-06 12:36:51 EDT; 12min ago
     Docs: man:systemd.special(7)

Jun 06 12:36:51 f26 systemd[1]: Reached target Remote File Systems.

The reason being, as Neil pointed out, the mount.nfs gets the 
ECONNREFUSED right away because the server is down. So a
child is quickly forked that continues to try the mount... 
Basically sneaking around systemd back... Which is hard
to do... these day 8-)  

steved.
