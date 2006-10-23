From: "Benham, Timothy MR" <Timothy.Benham@defence.gov.au>
Subject: Re: fcntl(3, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=0,
	len=0}) unreasonably slow SEC: UNCLASSIFIED
Date: Tue, 24 Oct 2006 09:21:09 +1000
Message-ID: <C172191424DC784385F213C8CBB4CDE015E1A5@rusrxm02.drn.mil.au>
References: <1161121776.5559.50.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gc97M-00083B-DP
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 16:22:04 -0700
Received: from defuim02a.defence.gov.au ([203.10.224.149])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gc97M-0007eX-5a
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 16:22:05 -0700
In-Reply-To: <1161121776.5559.50.camel@lade.trondhjem.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Thanks! we put up 2.6.9-42 and the program now runs without the 30s
delays.

It is still quite slow though when two instances are contending for the
lock. As an example, tess does 1000 open-lock-close cycles in about 1
second. If two instances are running, a 1000 cycles takes 40 seconds!

cheers,
Tim

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
Sent: Wednesday, 18 October 2006 07:50
To: Benham, Timothy MR
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] fcntl(3, F_SETLKW, {type=F_WRLCK,
whence=SEEK_SET,start=0, len=0}) unreasonably slow SEC: UNCLASSIFIED


On Tue, 2006-10-17 at 10:59 +1000, Benham, Timothy MR wrote:
> I've noticed a problem with NFS file locking under Linux kernel 
> 2.6.9-34.ELsmp. The server is a NetApp appliance. The problem was 
> initially discovered in a programs which access a file that holds 
> state for a distributed system. 30 second delays are unacceptable in 
> this application.
> 
> The problem is exhibited by a simple C program (let's call it tess) 
> like
> 
> ...
> while(1) { 
>         fd=open(myNFSfile,O_RDWR); 
>         fcntl(fd, F_SETLKW, &myLock); 
>         close(fd); 
>         fprintf(stderr,"."); 
> } 
> ...
> 
> It prints period to the screen quickly. However running two instances 
> at once (eg "tess & tess") prints periods really slowly. Every call to

> fcntl seems to take 30 seconds. If I compile and run tess under 
> Solaris 9 the problem is not manifested.
> 
> Sorry about a lack of code etc but the systems in question are all 
> air-gapped. I'm only an applications programmer so I don't have access

> to system logs, can't use tethereal, etc. Local systems support's 
> answer is to refer the question to Red Hat. Any clues on how I could 
> get my application working sooner than that would be appreciated.

I understand from other sources that a number of NLM fixes that are not
present in 2.6.9-34.EL have been backported by RedHat into 2.6.9-42.EL.
Have you tried that release?

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
