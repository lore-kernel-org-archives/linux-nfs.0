From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/2] Fix lockd panic
Date: Tue, 08 Jan 2008 22:02:47 -0500
Message-ID: <47843957.9060208@redhat.com>
References: <4781BE72.7050404@redhat.com> <18307.2757.579354.785142@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbYAICpm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 21:45:42 -0500
In-Reply-To: <18307.2757.579354.785142-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:

>
>If I'm reading this correctly, this bug is introduced by your previous
>patch.
>  
>
Depending on how you see the issue. From my end, I view this as the 
existing code has a "trap" and I fell into it. This is probably a chance 
to clean up this logic.

>The important difference between the old code and the new code here is
>that the old code tests "file->f_locks" while the new code iterates
>through i_flock to see if there are any lockd locks.
>
>f_locks is set to a count of lockd locks in nlm_traverse_locks which
>*was* always called by nlm_inspect_file which is called immediately
>before the code you are changing.
>But since your patch, nlm_inspect_file does not always call
>nlm_traverse_locks, so there is a chance that f_locks is wrong.
>
>With this patch, f_locks it not used at all any more.
>  
>
Yes, a fair description of the issue !

>Introducing a bug in one patch and fixing in the next is bad style.
>  
>
ok .....

>Some options:
>
> Have an initial patch which removes all references to f_locks and
> includes the change in this patch.  With that in place your main
> patch won't introduce a bug.  If you do this, you should attempt to
> understand and justify the performance impact (does nlm_traverse_files
> become quadratic in number of locks.  Is that acceptable?).
>
> Change the first patch to explicitly update f_count if you bypass the
> call to nlm_inspect_file.
>
> something else???
>  
>

Let's see what hch says in another email... will come back to this soon.

>So NAK for this one in it's current form... unless I've misunderstood
>something.
>
>  
>
I expect this :)

-- Wendy

