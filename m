From: Christoph Hellwig <hch@infradead.org>
Subject: Re: kthread: update lockd to use kthread
Date: Fri, 25 Aug 2006 14:58:24 +0100
Message-ID: <20060825135824.GA10659@infradead.org>
References: <44EEA5E5.6000509@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GGcD9-0000vU-ND
	for nfs@lists.sourceforge.net; Fri, 25 Aug 2006 06:59:03 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GGcD9-0003wp-3V
	for nfs@lists.sourceforge.net; Fri, 25 Aug 2006 06:59:04 -0700
To: Cedric Le Goater <clg@fr.ibm.com>
In-Reply-To: <44EEA5E5.6000509@fr.ibm.com>
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

>  	host->h_nsmstate = newstate;
>  	if (!host->h_reclaiming++) {
> +		struct task_struct* task;
> +
>  		nlm_get_host(host);
>  		__module_get(THIS_MODULE);
> -		if (kernel_thread(reclaimer, host, CLONE_KERNEL) < 0)
> +		task = kthread_run(reclaimer, host, "%s-reclaim", host->h_name);
> +		if (IS_ERR(task))
>  			module_put(THIS_MODULE);

Folks, this kind of patches is really useless.  If I wanted to just replace
kernel_thread() with kthread_run() I could do it myself in a day or two.

The whole point of the kthread API is that we now have a coherent set
of functions that deal with all aspects of kernel thread handling.  And
a conversion to that always involves rething the whole way a driver
uses kernel threads, and that's a good thing because most users were
buggy or at least rather odd.

sunrpc is not an exception to that, the thread handling is very interesting,
including things like using signals for various things possibly not waiting
for threads to exit.

If you don't feel like poking into all these nasty internal leave the
conversation to someone else, preferably a nfs developer.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
