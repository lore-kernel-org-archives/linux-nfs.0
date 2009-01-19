From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks (RFC)
Date: Mon, 19 Jan 2009 16:54:00 -0600
Message-ID: <20090119225400.GA23086@redhat.com>
References: <20081122011555.GA28485@fieldses.org> <20081124103313.0c779324@tleilax.poochiereds.net> <20081124170653.GF17862@fieldses.org> <20081213074042.2e8223c3@tleilax.poochiereds.net> <20081216193806.GC18928@fieldses.org> <20081216195635.GD18928@fieldses.org> <20081216161158.2d173667@tleilax.poochiereds.net> <20081217191453.GA16777@redhat.com> <20081217200156.GO4614@fieldses.org> <20090115163014.GA6602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51395 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257AbZASWyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 17:54:11 -0500
In-Reply-To: <20090115163014.GA6602@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Dec 17, 2008 at 03:01:56PM -0500, J. Bruce Fields wrote:
> > On Wed, Dec 17, 2008 at 01:14:53PM -0600, David Teigland wrote:
> > Also, since flc is never actually handed to the posix lock system, I
> > think it should be a "shallow" lock copy--so it should be created with
> > __locks_copy_lock().  Something like the below?

> (I'd like to do the s/locks_copy_lock/__locks_copy_lock/ in a separate
> patch since it's not directly related to fixing the bug.)

I haven't looked at why, but s/locks_copy_lock/__locks_copy_lock/ creates
problems with the file_lock's kept by the vfs.  With two programs doing
locking on an nfs client I get lots of messages like this on the server:

dlm: dlm_plock_callback: vfs lock error -11 num 20573 file
ffff88007e16a818 fl ffff88007dc796b0
dlm: dlm_plock_callback: vfs lock error -11 num 2055f file
ffff88007e16a818 fl ffff88007dc796b0
dlm: dlm_plock_callback: vfs lock error -11 num 2058b file
ffff880017cf56d0 fl ffff88007e566750
dlm: dlm_plock_callback: vfs lock error -11 num 2055c file
ffff88007e16a818 fl ffff88007e566750

(code modified to report the -11 / -EAGAIN)

And /proc/locks on the server has entries that look like:

54: POSIX  *NOINODE* WRITE 8682 <none>:0 5 9
55: POSIX  *NOINODE* READ  8682 <none>:0 0 4
56: POSIX  *NOINODE* READ  8682 <none>:0 0 4
57: POSIX  *NOINODE* READ  8682 <none>:0 5 9
58: POSIX  *NOINODE* READ  8682 <none>:0 5 9
59: POSIX  *NOINODE* WRITE 8682 <none>:0 0 4

My tests are looking good using the current locks_copy_lock(), so I plan
to just stick with that.
Dave

