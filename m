From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Wed, 09 Aug 2006 17:45:36 -0400
Message-ID: <1155159937.15624.22.camel@localhost>
References: <44DA25D3.3010003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAvs4-0004hv-Bf
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 14:45:48 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GAvs4-0003qD-C1
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 14:45:49 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <44DA25D3.3010003@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-08-09 at 14:13 -0400, Wendy Cheng wrote:
> I was testing NLM failover patches this morning and found the command 
> hangs. Look like nlm_traverse_files(), where it grabs nlm_file_mutex 
> early in the call, will have a chance to call nlm_release_file() via 
> nlmsvc_free_block() inside kref_put(). The nlm_release_file() wants 
> nlm_file_mutex too - this would generate a deadlock as the following:
> 
> dhcp59-234 kernel: Call Trace:
> [<c02dd749>] __mutex_lock_slowpath+0x4c/0x7e
> [<c02dd78a>] .text.lock.mutex+0xf/0x14
> [<f8afeacd>] nlm_release_file+0x2b/0xdf [lockd]
> [<f8afda90>] nlmsvc_free_block+0x8c/0x9d [lockd]
> [<f8afda04>] nlmsvc_free_block+0x0/0x9d [lockd]
> [<c01be98d>] kref_put+0x4e/0x58
> [<f8afd175>] nlmsvc_traverse_blocks+0xaf/0xc6 [lockd]
> [<f8afe960>] nlm_traverse_files+0x108/0x1cd [lockd]
> 
> The attached patch seems to fix the issue - it skips (defers) the file 
> removal. Eventually either nlm_gc_hosts (some time later when client is 
> unmonitored) or nlmsvc_traverse_files will finish the clean up.  Note 
> that this is a 10-minutes  work - not sure its ramification at this 
> moment. Take a look ?
> 
> -- Wendy
> 
> plain text document attachment (gfs_nlm_deadlock.patch)
> --- linux-2/fs/lockd/svclock.c	2006-08-08 10:20:16.000000000 -0400
> +++ linux/fs/lockd/svclock.c	2006-08-09 10:28:35.000000000 -0400
> @@ -264,7 +264,9 @@ static void nlmsvc_free_block(struct kre
>  
>  	nlmsvc_freegrantargs(block->b_call);
>  	nlm_release_call(block->b_call);
> -	nlm_release_file(block->b_file);
> +	down(&file->f_sema);
> +	file->f_count--;
> +	up(&file->f_sema);
>  	kfree(block);
>  }

Vetoed. The block holds a reference to the file. It _must_ call
nlm_release_file() in order to release that reference. It is in any case
a bug to grab file->f_sema without holding a reference to the file.

I suspect, rather, that the problem is due to nlmsvc_create_block()
incrementing file->f_count without holding the nlm_file_mutex. If we
convert it to an atomic_t instead, then that problem should be solved.

aside: Note also that we want to get rid of all that mark and sweep
braindamage in nlm_traverse_*() with all the silly counting of f_lock,
f_blocks, f_shares,.... and replace those variables with proper
references to the struct nlm_file by the locks, blocks (is already the
case?), and shares.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
