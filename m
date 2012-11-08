Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407Ab2KHM1p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Nov 2012 07:27:45 -0500
Date: Thu, 8 Nov 2012 07:27:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jack Wang <jack.wang.usish@gmail.com>
Cc: =?utf-8?Q?Mart=C3=ADn?= Cigorraga <msx@archlinux.us>, dahai_tian@usish.com,
        linux-nfs@vger.kernel.org
Subject: Re: hang problem when umount a nfs point
Message-ID: <20121108122742.GB22735@fieldses.org>
References: <1351760297.5369.1.camel@localhost>
 <CA+res+RTz9DC8TK3N3kFrSpeT-rgad1nk7amJdWP_Up9OW9KSg@mail.gmail.com>
 <CAJLw8+WJGPiWW6K7UEX72eYdgeYWsDLcoZKNP7V1UvvQGnMxXA@mail.gmail.com>
 <CA+res+RhNJT1D0MpdSBJoywemainEJVZKSzG1BxhXTrQ3kQCbw@mail.gmail.com>
 <20121107190111.GC7421@fieldses.org>
 <CA+res+SD_mradA6grZz_80uWiidb_r9Kv_aW8rXVXpNLSozjWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+res+SD_mradA6grZz_80uWiidb_r9Kv_aW8rXVXpNLSozjWA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 08, 2012 at 11:03:22AM +0800, Jack Wang wrote:
> 2012/11/8 J. Bruce Fields <bfields@fieldses.org>:
> > On Wed, Nov 07, 2012 at 09:05:51AM +0800, Jack Wang wrote:
> >> 2012/11/7 Martín Cigorraga <msx@archlinux.us>:
> >> > On Mon, Nov 5, 2012 at 10:27 PM, Jack Wang <jack.wang.usish@gmail.com>
> >> > wrote:
> >> >>
> >> >> Hi all,
> >> >>
> >> >> Anyone who can kindly give some suggestion? or we just put question to
> >> >> the wrong list?
> >> >>
> >> >> Thanks.
> >> >>
> >> >> Jack
> >> >>
> >> >> 2012/11/1 dahai_tian <dahai_tian@usish.com>:
> >> >> > Hi all:
> >> >> >         I mount a local directory to a nfs server. When nfs server is
> >> >> > stopped
> >> >> > for some accidental cause, I try to umount the mount point, the umount
> >> >> > command will hang and 'time out' messages are continually printed in the
> >> >> > terminal. How can I avoid hanging in this case? BTW, This issue does not
> >> >> > exist when I changed nfs version from 4 to 3.
> >> >> >         Look forward to your response, thanks!
> >>
> >> >
> >> > Hi Jack, use the -l (lazy) switch:
> >> > # umount -l {your mounted nfs share}
> >> >
> >> > Also, I wouldn't recommend 'just to kill' the NFS proces(ses) as it (them)
> >> > may leave shared memory a mess.
> >> > (And I would like to see how do you make to mount any NFS share again
> >> > without booting)
> >>
> >> Thanks Martin for kindly help.
> >>
> >> umount -l did work, but why nfsv3 do not have this problem?
> >
> > I don't know what it is exactly.  But in general I wouldn't expect
> > umount to work when the server's unavailable.
> >
> > --b.
> 
> Thanks for your time Bruce, but there are chance the server
> unavailable , why you think umount don't work is expected?

It's tough for the client to deal safely with an unreachable server.
Worst case it may still have data in its buffers that applications have
written but that hasn't yet made it to the server.

If you don't have any opens or other state on the filesystem any more,
there might be things that could be done to make it easier to umount in
that case--I haven't thought it through--but I doubt that's a high
priority, so it's likely up to you to write the code and persuade people
it's worthwhile.

--b.
