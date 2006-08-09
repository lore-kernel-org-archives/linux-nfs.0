From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Wed, 09 Aug 2006 18:07:59 -0400
Message-ID: <44DA5CBF.3040309@redhat.com>
References: <44DA25D3.3010003@redhat.com> <1155159937.15624.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAwL5-0007Gm-Sk
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 15:15:47 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1GAwEZ-0005bC-DQ
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 15:09:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAwEY-0007DY-WC
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 15:09:03 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1155159937.15624.22.camel@localhost>
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

Trond Myklebust wrote:

>On Wed, 2006-08-09 at 14:13 -0400, Wendy Cheng wrote:
>  
>
>>I was testing NLM failover patches this morning and found the command 
>>hangs. Look like nlm_traverse_files(), where it grabs nlm_file_mutex 
>>early in the call, will have a chance to call nlm_release_file() via 
>>nlmsvc_free_block() inside kref_put(). The nlm_release_file() wants 
>>nlm_file_mutex too - this would generate a deadlock as the following:
>>
>>dhcp59-234 kernel: Call Trace:
>>[<c02dd749>] __mutex_lock_slowpath+0x4c/0x7e
>>[<c02dd78a>] .text.lock.mutex+0xf/0x14
>>[<f8afeacd>] nlm_release_file+0x2b/0xdf [lockd]
>>[<f8afda90>] nlmsvc_free_block+0x8c/0x9d [lockd]
>>[<f8afda04>] nlmsvc_free_block+0x0/0x9d [lockd]
>>[<c01be98d>] kref_put+0x4e/0x58
>>[<f8afd175>] nlmsvc_traverse_blocks+0xaf/0xc6 [lockd]
>>[<f8afe960>] nlm_traverse_files+0x108/0x1cd [lockd]
>>
>>The attached patch seems to fix the issue - it skips (defers) the file 
>>removal. Eventually either nlm_gc_hosts (some time later when client is 
>>unmonitored) or nlmsvc_traverse_files will finish the clean up.  Note 
>>that this is a 10-minutes  work - not sure its ramification at this 
>>moment. Take a look ?
>>
>>-- Wendy
>>
>>plain text document attachment (gfs_nlm_deadlock.patch)
>>--- linux-2/fs/lockd/svclock.c	2006-08-08 10:20:16.000000000 -0400
>>+++ linux/fs/lockd/svclock.c	2006-08-09 10:28:35.000000000 -0400
>>@@ -264,7 +264,9 @@ static void nlmsvc_free_block(struct kre
>> 
>> 	nlmsvc_freegrantargs(block->b_call);
>> 	nlm_release_call(block->b_call);
>>-	nlm_release_file(block->b_file);
>>+	down(&file->f_sema);
>>+	file->f_count--;
>>+	up(&file->f_sema);
>> 	kfree(block);
>> }
>>    
>>
>
>Vetoed. The block holds a reference to the file. It _must_ call
>nlm_release_file() in order to release that reference. It is in any case
>a bug to grab file->f_sema without holding a reference to the file.
>
>I suspect, rather, that the problem is due to nlmsvc_create_block()
>incrementing file->f_count without holding the nlm_file_mutex. If we
>convert it to an atomic_t instead, then that problem should be solved.
>  
>

Disagree ! :)

The whole thing is about deadlock, not about reference count. Look at 
the logic ... nlm_traverse_files grabs the nlm_file_mutex, then comes 
down to nlm_release_file where it tries to get nlm_file_mutex lock 
again. I'll need to run now - we can discuss this tomorrow morning. 
Please re-read the issue and we'll discuss later.

-- Wendy

>aside: Note also that we want to get rid of all that mark and sweep
>braindamage in nlm_traverse_*() with all the silly counting of f_lock,
>f_blocks, f_shares,.... and replace those variables with proper
>references to the struct nlm_file by the locks, blocks (is already the
>case?), and shares.
>
>Cheers,
>  Trond
>
>  
>

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
