Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50360 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752576AbdKHPwD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 10:52:03 -0500
Date: Wed, 8 Nov 2017 10:52:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: NeilBrown <neilb@suse.com>, Joshua Watt <jpewhacker@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Subject: Re: NFS Force Unmounting
Message-ID: <20171108155203.GK24262@fieldses.org>
References: <1508951506.2542.51.camel@gmail.com>
 <20171030202045.GA6168@fieldses.org>
 <87h8ugwdev.fsf@notabene.neil.brown.name>
 <1509557061.4755.27.camel@redhat.com>
 <87efphvbhy.fsf@notabene.neil.brown.name>
 <1509624549.4569.28.camel@redhat.com>
 <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
 <87fu9ph2g7.fsf@notabene.neil.brown.name>
 <1510142905.8401.6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1510142905.8401.6.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 08, 2017 at 07:08:25AM -0500, Jeff Layton wrote:
> On Wed, 2017-11-08 at 14:30 +1100, NeilBrown wrote:
> > What to people think of the following as an approach
> > to Joshua's need?
> > 
> > It isn't complete by itself: it needs a couple of changes to
> > nfs-utils so that it doesn't stat the mountpoint on remount,
> > and it might need another kernel change so that the "mount" system
> > call performs the same sort of careful lookup for remount as  the umount
> > system call does, but those are relatively small details.
> > 
> 
> Yeah, that'd be good.
> 
> > This is the patch that you will either love of hate.
> > 
> > With this patch, Joshua (or any other sysadmin) could:
> > 
> >   mount -o remount,retrans=0,timeo=1 /path
> > 
> > and then new requests on any mountpoint from that server will timeout
> > quickly.
> > Then
> >   umount -f /path
> >   umount -f /path
...
> Looks like a reasonable approach overall to preventing new RPCs from
> being dispatched once the "force" umount runs.

I've lost track of the discussion--after this patch, how close are we to
a guaranteed force unmount?  I assume there are still a few obstacles.

> I do wonder if this ought to be more automatic when you specify -f on
> the umount. Having to manually do a remount first doesn't seem very
> admin-friendly.

It's an odd interface.  Maybe we could wrap it in something more
intuitive.

I'd be nervous about making "umount -f" do it.  I think administrators
could be unpleasantly surprised in some cases if an "umount -f" affects
other mounts of the same server.

--b.
