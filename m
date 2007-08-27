From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/15] knfsd: spawn kernel thread to probe callback
	channel
Date: Mon, 27 Aug 2007 19:36:15 -0400
Message-ID: <20070827233615.GP3118@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org> <1188246176681-git-send-email-bfields@fieldses.org> <1188246176897-git-send-email-bfields@fieldses.org> <1188246177833-git-send-email-bfields@fieldses.org> <11882461773576-git-send-email-bfields@fieldses.org> <11882461771774-git-send-email-bfields@fieldses.org> <1188246177195-git-send-email-bfields@fieldses.org> <11882461773396-git-send-email-bfields@fieldses.org> <1188246177259-git-send-email-bfields@fieldses.org> <18131.23980.89642.364179@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Adrian Bunk <bunk@kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759607AbXH0Xg3@vger.kernel.org>
In-Reply-To: <18131.23980.89642.364179@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Aug 28, 2007 at 09:26:36AM +1000, Neil Brown wrote:
> On Monday August 27, bfields@fieldses.org wrote:
> >  
> > +/* Reference counting, callback cleanup, etc., all look racy as heck.
> > + * And why is cb_set an atomic? */
> 
> Agreed.... so do we really want this code in mainline?  is the old
> code so bad that this is better?

The code in question is just moved, not rewritten, so those are
preexisting problems that I was just adding a whiny comment about in
hopes it would remind me some more patches were probably needed.
(Thanks for the reminder....)

>  - cb_set should not be atomic.
>  - This looks like a job for async-rpc rather than a kernel thread

The problem isn't the wait for the rpc itself, it's the creation of the
new cred that's needed in the gss case.  That could also be made
asynchronous, but as there's several other delicate changes in the
pipeline (keyring stuff, etc.), I'd rather not touch it for now.

>  - If you do use a thread, you at least want __module_get before
>    starting the thread, and module_put_and_exit to terminate the
>    thread.
>  - Can you just use 'cb_client' rather than cb_set?  If you move
>    rpc_create into the thread, you don't need to set cb_client until
>    the callback is successful.  Then add a 'cb_active' flag bit
>    so that you don't have two callbacks at the same time, and it
>    should be less racy..

Yep, probably so.

--b.
