From: Ulrich Gemkow <gemkow@ikr.uni-stuttgart.de>
Subject: Re: exportfs -u hangs on SMP
Date: Sat, 26 Jul 2003 12:55:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200307261255.29823.gemkow@ikr.uni-stuttgart.de>
References: <20030720103649.A20763@ikr.uni-stuttgart.de> <16155.8767.278825.712370@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gate.ikr.uni-stuttgart.de ([129.69.170.1])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19gMiB-00061j-00
	for <nfs@lists.sourceforge.net>; Sat, 26 Jul 2003 03:55:39 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16155.8767.278825.712370@gargle.gargle.HOWL>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello Neil,

I tested the patch and our server survived for almost one week now - much
longer than without the patch. So it seems the patch solves the problem
and would be helpful in mainline too.

Thank you again for your quick help and greetings

Ulrich

> On Sunday July 20, gemkow@ikr.uni-stuttgart.de wrote:
> > Now sometimes we have hangs of "exportfs -u". The process hangs and is
> > not killable. The server works normal except that it is no longer
> > responding to NFS requests. Only a reboot of the server helps.
> >
> > The "hang rate" is about once per day with 20 users and 5 directories
> > exported on login for each user. The server has medium to high NFS-load.
> >
> > The hangs only happen when the server is running a SMP-enabled kernel.
> > When using a non-SMP-kernel on the same hardware, the hangs are not
> > happening.
> >
> > Environment is Linux 2.4.21 (vanilla), nfs-utils 1.0.1 (vanilla,
> > xlog-patch applied), glibc 2.3 (RedHat 9 based) on a 2-processor PIII
> > hardware.
>
> Could you try this patch please?
> Most of the nfsd is under the BigKernelLock in 2.4, so SMP or not
> shouldn't have much effect.  However I just found a bit that isn't
> under the lock, and it could be causing your problem.
>
> If you do test it, please let me know how it goes.
>
> Thanks,
> NeilBrown
>
>
> diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
> --- ./fs/nfsd/export.c~current~	2003-07-21 09:12:01.000000000 +1000
> +++ ./fs/nfsd/export.c	2003-07-21 09:12:16.000000000 +1000
> @@ -19,6 +19,7 @@
>  #include <linux/stat.h>
>  #include <linux/in.h>
>  #include <linux/seq_file.h>
> +#include <linux/smp_lock.h>
>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/nfsd/nfsd.h>
> @@ -571,6 +572,7 @@ static void *e_start(struct seq_file *m,
>  	svc_client *clp;
>  	struct list_head *p;
>
> +	lock_kernel();
>  	exp_readlock();
>  	if (!n--)
>  		return (void *)1;
> @@ -622,6 +624,7 @@ static void *e_next(struct seq_file *m,
>  static void e_stop(struct seq_file *m, void *p)
>  {
>  	exp_unlock();
> +	unlock_kernel();
>  }
>
>  struct flags {

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
