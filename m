Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753529Ab3FOLGP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Jun 2013 07:06:15 -0400
Date: Sat, 15 Jun 2013 07:05:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Simo <idra@samba.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 06/14] locks: don't walk inode->i_flock list in
 locks_show
Message-ID: <20130615070535.6367eed9@tlielax.poochiereds.net>
In-Reply-To: <51BB040C.3050101@samba.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
	<1370948948-31784-7-git-send-email-jlayton@redhat.com>
	<20130613194545.GC19218@fieldses.org>
	<20130613162648.176979bc@tlielax.poochiereds.net>
	<51BB040C.3050101@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 14 Jun 2013 07:52:44 -0400
Simo <idra@samba.org> wrote:

> On 06/13/2013 04:26 PM, Jeff Layton wrote:
> > The only real solution I can think of is to put flock locks into the
> > blocked_list/blocked_hash too, or maybe giving them a simple hlist to
> > sit on.
> >
> > I'll fix that up in the next iteration. It'll probably make flock()
> > tests run slower, but such is the cost of preserving this procfile...
> 
> How hard would it be to make the procfile stuff optional ?
> So that those that need performance can decide to not use it ?
> Maybe even something that can be disabled at run time ? Not just compile 
> time.
> 

(re-adding back the cc lists...)

It'd be tricky, especially if you want to do it at runtime. The
procfile itself is not a problem per-se. The real problem is the
tracking you have to do in order to eventually present the procfile. So
a boot-time or compile-time switch might be reasonable, but a runtime
switch will probably never really be.

I have a new patchset that I'm testing now though that should address
Bruce's concerns about iterating over that global list. So far, it
seems to be at least as fast as the latest patchset I posted.

It makes the (spin)locking a bit more complex, but hopefully I can
document this well enough that it's not a great concern.

Stay tuned...

-- 
Jeff Layton <jlayton@redhat.com>
