From: Jonathan Couper <jonathan-3c88B9b11vOEi8DpZVb4nw@public.gmane.org>
Subject: Re: Mutex Hang on GC in lockd for 2.6.22-14
Date: Tue, 22 Jan 2008 09:49:08 +1300
Message-ID: <47950544.2080205@spiderfan.org>
References: <479427C5.8020203@spiderfan.org>
 <18324.11227.8442.938224@notabene.brown> <47942CA4.1060700@spiderfan.org>
 <20080121183121.GJ17468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4.clear.net.nz ([203.97.37.64]:59565 "EHLO
	smtp4.clear.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754422AbYAUUtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 15:49:13 -0500
Received: from [192.168.1.210]
 (121-72-69-175.dsl.telstraclear.net [121.72.69.175])
 by smtp4.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0JV00038RHTWLU20-ik10VMwhufF/PQoK6HpaanTaI6DYlTYJ@public.gmane.org> for
 linux-nfs@vger.kernel.org; Tue, 22 Jan 2008 09:49:11 +1300 (NZDT)
In-reply-to: <20080121183121.GJ17468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Heya,

	What's the path for that getting rolled back into the 2.6.22 chain?  In 
  generally I'm happy with my 2.6.22 kernel.  Is Jeff submitting those 
fixes to the 2.6.22 release at some stage, do you know?

	J.

J. Bruce Fields wrote:
> On Mon, Jan 21, 2008 at 06:24:52PM +1300, Jonathan Couper wrote:
>> Heya NFS Experts,
>>
>> 	I'm pretty darn sure I've found (and am currently testing a fix for) a  
>> mutex bug in lockd that hangs NFS server pretty reliably.  I have no  
>> idea how this bug has gone unnoticed for so long, since this is the
>> current Gutsy Gibbon kernel!
>>
>> 	That makes me think that maybe I'm mistaken.  But my system definitely  
>> hangs, and the code definitely appears to attempt to lock twice on a  
>> non-recursive mutex.
>>
>> 	All the details are:
>>
>> https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/181996	
> 
> Hm; from:
> 
> 	https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/181996/comments/2
> 
> 	"...and on the server side I will now see TWO "[lockd]"
> 	processes where before I saw one."
> 
> That at least should be prevented by Jeff Layton's recent patches, which
> you can get from
> 
> 	git://linux-nfs.org/~bfields/linux.git nfs-server-stable
> 
> (Quick git tutorial; you can get that with
> 
> 	apt-get install git-core
> 	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> 	cd linux-2.6
> 	git remote add bfields git://linux-nfs.org/~bfields/linux.git
> 	git fetch bfields
> 	git checkout bfields/nfs-server-stable
> 
> )
> 
> But, hm, I'm confused by your description in:
> 
> 	https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/181996/comments/10
> 
> The double-lock you're identifying is from:
> 
> 	nlmsvc_lock() taking f_mutex, then calling
> 		nlmsvc_create_block(), which calls
> 			nlmsvc_lookup_host()
> 
> but nlmsvc_create_block() doesn't call nlmsvc_lookup_host().  Oh, I
> see--it used to in v2.6.22; the commit below fixed it.  (And note if you
> apply that you should also apply
> a6d85430424d44e946e0946bfaad607115510989 "NLM: Fix a memory leak in
> nlmsvc_testlock"
> 
>> 	I'd LOVE to get my name into the Linux Kernel.  Please tell me I've  
>> found a real bug!
> 
> Alas!  So the secret is to test the most recent kernels, as those have
> the most unfound bugs....
> 
> --b.
> 
> commit 255129d1e9ca0ed3d69d5517fae3e03d7ab4b806
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Sep 25 15:55:03 2007 -0400
> 
>     NLM: Fix a circular lock dependency in lockd
>     
>     The problem is that the garbage collector for the 'host' structures
>     nlm_gc_hosts(), holds nlm_host_mutex while calling down to
>     nlmsvc_mark_resources, which, eventually takes the file->f_mutex.
>     
>     We cannot therefore call nlmsvc_lookup_host() from within
>     nlmsvc_create_block, since the caller will already hold file->f_mutex, so
>     the attempt to grab nlm_host_mutex may deadlock.
>     
>     Fix the problem by calling nlmsvc_lookup_host() outside the file->f_mutex.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index a21e4bc..d098c7a 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -171,19 +171,14 @@ found:
>   * GRANTED_RES message by cookie, without having to rely on the client's IP
>   * address. --okir
>   */
> -static inline struct nlm_block *
> -nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_file *file,
> -		struct nlm_lock *lock, struct nlm_cookie *cookie)
> +static struct nlm_block *
> +nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
> +		    struct nlm_file *file, struct nlm_lock *lock,
> +		    struct nlm_cookie *cookie)
>  {
>  	struct nlm_block	*block;
> -	struct nlm_host		*host;
>  	struct nlm_rqst		*call = NULL;
>  
> -	/* Create host handle for callback */
> -	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
> -	if (host == NULL)
> -		return NULL;
> -
>  	call = nlm_alloc_call(host);
>  	if (call == NULL)
>  		return NULL;
> @@ -366,6 +361,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
>  			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
>  {
>  	struct nlm_block	*block = NULL;
> +	struct nlm_host		*host;
>  	int			error;
>  	__be32			ret;
>  
> @@ -377,6 +373,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
>  				(long long)lock->fl.fl_end,
>  				wait);
>  
> +	/* Create host handle for callback */
> +	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
> +	if (host == NULL)
> +		return nlm_lck_denied_nolocks;
>  
>  	/* Lock file against concurrent access */
>  	mutex_lock(&file->f_mutex);
> @@ -385,7 +385,8 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
>  	 */
>  	block = nlmsvc_lookup_block(file, lock);
>  	if (block == NULL) {
> -		block = nlmsvc_create_block(rqstp, file, lock, cookie);
> +		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
> +				lock, cookie);
>  		ret = nlm_lck_denied_nolocks;
>  		if (block == NULL)
>  			goto out;
> @@ -449,6 +450,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
>  out:
>  	mutex_unlock(&file->f_mutex);
>  	nlmsvc_release_block(block);
> +	nlm_release_host(host);
>  	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
>  	return ret;
>  }
> @@ -477,10 +479,15 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
>  
>  	if (block == NULL) {
>  		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
> +		struct nlm_host	*host;
>  
>  		if (conf == NULL)
>  			return nlm_granted;
> -		block = nlmsvc_create_block(rqstp, file, lock, cookie);
> +		/* Create host handle for callback */
> +		host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
> +		if (host == NULL)
> +			return nlm_lck_denied_nolocks;
> +		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
>  		if (block == NULL) {
>  			kfree(conf);
>  			return nlm_granted;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

