Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f45.google.com ([74.125.83.45]:59270 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab3CHOBj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 09:01:39 -0500
Date: Fri, 8 Mar 2013 15:01:34 +0100
From: Ingo Molnar <mingo@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Tejun Heo <tj@kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130308140134.GA28413@gmail.com>
References: <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
 <20130306212452.GO1227@htj.dyndns.org>
 <CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
 <20130306213636.GP1227@htj.dyndns.org>
 <20130307064140.71c0936b@tlielax.poochiereds.net>
 <CA+55aFxe1_x8wvVYciiX8tuee+VsmXGKqEbONQdFM4s4W2iuPg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286B511E@sacexcmbx05-prd.hq.netapp.com>
 <CA+55aFySyBP8q5AvPrt-s_ZPdgamfoX-dERw4EJ21EcsDLBjYA@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286B52F1@sacexcmbx05-prd.hq.netapp.com>
 <CA+55aFwB4Pjki8zg9idwbQbE-TOtTdD5o8d_r1=NY3veVqmPHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwB4Pjki8zg9idwbQbE-TOtTdD5o8d_r1=NY3veVqmPHg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

>  - the "freeezer for suspend/resume on a laptop"
> 
> [...]
> 
> The second one is unlikely to really use NFS anyway. [...]

<me raises a hand>

Incidentally I use NFS to a file server on my laptop, over wifi, and I close the lid 
for the night. It's NFS mounted soft.

If it was mounted hard I wouldn't expect the lid close event to result in a 
successful suspend if wifi went down - but with soft I would be pretty sad in the 
morning if batteries drained if I closed the lid after there's a power outage which 
took down both wifi and the laptop power supply.

Closing the lid while on battery is a pretty strong command from the user.

Arguably this is a special case on several levels as on desktop distros it's not at 
all easy mount NFS shares (all point & click automation goes to Samba shares), just 
wanted to mention it.

Thanks,

	Ingo
