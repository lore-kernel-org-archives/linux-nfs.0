From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
	kernel
Date: Wed, 12 Jan 2005 19:38:01 -0500
Message-ID: <1105576681.14443.100.camel@lade.trondhjem.org>
References: <41DD8403.7030601@RedHat.com>
	 <1105118040.10979.70.camel@lade.trondhjem.org>
	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>
	 <41E43DE1.5080703@RedHat.com>
	 <1105480745.11430.56.camel@lade.trondhjem.org> <41E569E3.20206@RedHat.com>
	 <1105554342.23943.1.camel@lade.trondhjem.org> <41E5767F.40204@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cot0A-0004bT-Sq
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 16:38:14 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cot09-0003UI-5V
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 16:38:14 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41E5767F.40204@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

on den 12.01.2005 Klokka 14:11 (-0500) skreiv Steve Dickson:

> Here is what I found.... just adding the PF_DUMPCORE rpc_clnt_sigmask() 
> no core was dropped
> because __rpc_execute returned -ERESTARTSYS due to signalled() == TRUE.
> 
> When I added back the  PF_DUMPCORE check to __rpc_execute(), only the 
> header of the core
> was dropped  because nfs_wait_event() returned -ERESTARTSYS because 
> signalled() == TRUE.
> 
> When I added back the PF_DUMPCORE to nfs_wait_event(), the entire core 
> was dropped.
> 
> So it appears to me that you need both checks.....

No! Those extra checks are neither necessary, nor are they even correct!
I repeat what I said in my earlier mail:

        - The change to nfs_wait_event() converts it into an
        unconditional uninterruptible sleep. That means you can never
        "kill -9" out of waiting for the core dump to finish in case the
        server crashes!

        - The loop you add to __rpc_execute() is pointless: The signal
        that caused your process to wake up is neither cleared nor
        masked, so when it later tries to block (such as when waiting
        for a reply from the server), that process will just find itself
        immediately woken up again by the same signal.
        IOW: any milage you are getting out of this change will be 100%
        timing-dependent. Not being able to wait for replies from the
        server, you are depending entirely on the server to reply so
        quickly that it appears to be "instantaneous".
...

As for myself, I'm getting full coredumps when I apply the 2 line patch
I sent you. The appended testcase works every time:

[trondmy@trondheim trondmy]$ uname -a
Linux trondheim.citi.umich.edu 2.4.29-rc2 #3 on jan 12 19:12:57 EST 2005 i686 athlon i386 GNU/Linux
[trondmy@trondheim trondmy]$ ./a.out
Quit (core dumped)
[trondmy@trondheim trondmy]$ ls -l core.1657
-rw-------  1 trondmy users 16953344 jan 12 19:36 core.1657

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>


---------------------------------------
#include <signal.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>


#define CORESIZE (1024*1024*16)
int main()
{
	void *ptr;
	struct rlimit rlimit = {
		.rlim_cur = RLIM_INFINITY,
		.rlim_max = RLIM_INFINITY
	};

	/* Ensure we are set to create core dump files */
	if (setrlimit(RLIMIT_CORE, &rlimit) < 0) {
		perror("setrlimit failed!");
		exit(1);
	}

	/* Ensure coredump is large! */
	ptr = malloc(CORESIZE);
	memset(ptr, '0', CORESIZE);

	/* raise hell */
	raise(SIGQUIT);
}




-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
