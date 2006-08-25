From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: kthread: update lockd to use kthread
Date: Fri, 25 Aug 2006 19:07:59 +0200
Message-ID: <44EF2E6F.1040905@fr.ibm.com>
References: <44EEA5E5.6000509@fr.ibm.com>
	<20060825135824.GA10659@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GGfAF-0003bR-CA
	for nfs@lists.sourceforge.net; Fri, 25 Aug 2006 10:08:15 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GGfAE-0005jI-EY
	for nfs@lists.sourceforge.net; Fri, 25 Aug 2006 10:08:16 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7PH85wD029738
	for <nfs@lists.sourceforge.net>; Fri, 25 Aug 2006 13:08:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k7PH85Yu163982
	for <nfs@lists.sourceforge.net>; Fri, 25 Aug 2006 11:08:05 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k7PH85r5030496
	for <nfs@lists.sourceforge.net>; Fri, 25 Aug 2006 11:08:05 -0600
To: Christoph Hellwig <hch@infradead.org>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
In-Reply-To: <20060825135824.GA10659@infradead.org>
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

Hello !

Christoph Hellwig wrote:
>>  	host->h_nsmstate = newstate;
>>  	if (!host->h_reclaiming++) {
>> +		struct task_struct* task;
>> +
>>  		nlm_get_host(host);
>>  		__module_get(THIS_MODULE);
>> -		if (kernel_thread(reclaimer, host, CLONE_KERNEL) < 0)
>> +		task = kthread_run(reclaimer, host, "%s-reclaim", host->h_name);
>> +		if (IS_ERR(task))
>>  			module_put(THIS_MODULE);
> 
> Folks, this kind of patches is really useless.  If I wanted to just replace
> kernel_thread() with kthread_run() I could do it myself in a day or two.

ok ok. The real work that needs to be done is in sunrpc and I'm still
*very* far from providing any patches.

This kernel thread is a sub thread of the lockd thread. It's a bit more
simple and does not require as much modification. It still depends on the
way its parent is killed and it will require some more work when the sunrpc
thread are fixed.

> The whole point of the kthread API is that we now have a coherent set
> of functions that deal with all aspects of kernel thread handling.  And
> a conversion to that always involves rething the whole way a driver
> uses kernel threads, and that's a good thing because most users were
> buggy or at least rather odd.
>
> sunrpc is not an exception to that, the thread handling is very interesting,
> including things like using signals for various things possibly not waiting
> for threads to exit.

The SIGKILL used to terminate the threads is a challenge ... it propagates
to sub threads. Some other stuff that bother me in using the kthread api in
sunrpc : nfs_callback_down() uses a wait on a completion with a timeout.
This is not possible with the kthread but might not be really useful. dunno.

We might need some enhancements to kthread to make everyone happy or some
work around in the model.

> If you don't feel like poking into all these nasty internal leave the
> conversation to someone else, preferably a nfs developer.

They would certainly do a better job than me. I'm discovering the code.

Thanks,

C.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
