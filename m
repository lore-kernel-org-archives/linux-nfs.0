From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Wed, 06 Dec 2006 22:47:46 -0800
Message-ID: <4577B912.2030500@almaden.ibm.com>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu> <20061206154951.GB16378@redhat.com> <20061206195722.GH1714@fieldses.org> <20061206205822.GB25322@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: David Teigland <teigland@redhat.com>
In-Reply-To: <20061206205822.GB25322@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Here is a rewrite of gdlm_plock_callback(). We still need to add the 
lock cancel.
Marc.

int gdlm_plock_callback(struct plock_op *op)
{
     struct file *file;
     struct file_lock *fl;
     int (*notify)(void *, void *, int) = NULL;
     int rv;

    spin_lock(&ops_lock);
    if (!list_empty(&op->list)) {
        printk(KERN_INFO "plock op on list\n");
        list_del(&op->list);
    }
    spin_unlock(&ops_lock);

    rv = op->info.rv;

    /* check if the following 2 are still valid or make a copy */
    file = op->info.file;
    fl = op->info.fl;
    notify = op->info.callback;

    if (!rv) { /* got fs lock */
        rv = posix_lock_file(file, fl);
        if (rv) { /* did not get posix lock */
            notify(fl, NULL, rv);
            log_error("gdlm_plock: vfs lock error file %p fl %p",
                  file, fl);
            /* XXX: We need to cancel the fs lock here: */
            printk("gfs2 lock posix lock request failed\n");
        }
        else { /* got posix lock */
            if (notify(fl, NULL, 0)) {
                /* XXX: We need to cancel the fs lock here: */
                printk("gfs2 lock granted after lock request failed; 
dangling lock!\n");
            }
        }
    }
    else {  /* did not get fs lock */
        notify(fl, NULL, rv);
    }

    kfree(op);
    return rv;
}


David Teigland wrote:

>On Wed, Dec 06, 2006 at 02:57:22PM -0500, J. Bruce Fields wrote:
>  
>
>>On Wed, Dec 06, 2006 at 09:49:51AM -0600, David Teigland wrote:
>>    
>>
>>>The gfs side looks fine to me.  Did you forget to call fl_notify from
>>>gdlm_plock_callback() or am I missing something?
>>>      
>>>
>>Yes, looks like we missed something, thanks.  This code's an rfc (not
>>even tested), so don't apply it yet!  What we should have there is
>>something like:
>>
>>	rv = op->info.rv;
>>
>>	if (fl_notify(fl, NULL, rv)) {
>>		/* XXX: We need to cancel the lock here: */
>>		printk("gfs2 lock granted after lock request failed; dangling lock!\n");
>>	}
>>
>>	if (!rv) {
>>		/* check if the following are still valid or make a copy */
>>		file = op->info.file;
>>		fl = op->info.fl;
>>		
>>		if (posix_lock_file_wait(file, fl) < 0)
>>			log_error("gdlm_plock: vfs lock error file %p fl %p",
>>				  file, fl);
>>	}
>>
>>Note there's a race condition--that calls fl_notify before actually
>>getting the lock locally.  I don't *think* that's a problem, as long as
>>it's the filesystem and not the local lock list that's authoritative
>>when it comes to who gets a posix lock.
>>    
>>
>
>agree
>
>  
>
>>The more annoying problem is the need to cancel the GFS lock when
>>fl_notify fails; is that something that it's possible for GFS to do?
>>
>>It can fail because lockd has a timeout--it waits a few seconds for the
>>callback, then gives up and returns a failure to the user.  If that
>>happens after your userspace posix lock manager acquires the lock (but
>>before fl_notify is called) then you've got to cancel it somehow.
>>    
>>
>
>I'd think we could just send an unlock for it at that point.  Set up an op
>with GDLM_PLOCK_OP_UNLOCK and the same fields as the lock you're removing
>and call send_op().  We probably need to flag this internal-unlock op so
>that when the result arrives, device_write() delists and frees it itself.
>
>(I wouldn't call this "canceling", I think of cancel as trying to force a
>blocked request to return/fail prematurely.)
>
>Dave
>
>  
>

