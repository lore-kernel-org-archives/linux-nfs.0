From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 08/15] knfsd: spawn kernel thread to probe callback channel
Date: Tue, 28 Aug 2007 09:26:36 +1000
Message-ID: <18131.23980.89642.364179@notabene.brown>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
	<1188246177259-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Adrian Bunk <bunk@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758024AbXH0X05@vger.kernel.org>
In-Reply-To: message from J. Bruce Fields on Monday August 27
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Monday August 27, bfields@fieldses.org wrote:
>  
> +/* Reference counting, callback cleanup, etc., all look racy as heck.
> + * And why is cb_set an atomic? */

Agreed.... so do we really want this code in mainline?  is the old
code so bad that this is better?

 - cb_set should not be atomic.
 - This looks like a job for async-rpc rather than a kernel thread
 - If you do use a thread, you at least want __module_get before
   starting the thread, and module_put_and_exit to terminate the
   thread.
 - Can you just use 'cb_client' rather than cb_set?  If you move
   rpc_create into the thread, you don't need to set cb_client until
   the callback is successful.  Then add a 'cb_active' flag bit
   so that you don't have two callbacks at the same time, and it
   should be less racy..


The other 14 patches all look ok.

Thanks,
NeilBrown
