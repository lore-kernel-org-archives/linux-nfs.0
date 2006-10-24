From: "Benham, Timothy MR" <Timothy.Benham@defence.gov.au>
Subject: Re: fcntl(3, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=0,
	len=0}) unreasonably slow SEC: UNCLASSIFIED
Date: Tue, 24 Oct 2006 10:35:01 +1000
Message-ID: <C172191424DC784385F213C8CBB4CDE015E1A6@rusrxm02.drn.mil.au>
References: <C172191424DC784385F213C8CBB4CDE015E1A5@rusrxm02.drn.mil.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcAGE-0006Z3-So
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 17:35:18 -0700
Received: from defuim01a.defence.gov.au ([203.10.224.150])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcAGD-0000q1-Le
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 17:35:20 -0700
In-Reply-To: <C172191424DC784385F213C8CBB4CDE015E1A5@rusrxm02.drn.mil.au>
To: "Benham, Timothy MR" <Timothy.Benham@defence.gov.au>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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

-----Original Message-----
From: nfs-bounces@lists.sourceforge.net
[mailto:nfs-bounces@lists.sourceforge.net] On Behalf Of Benham, Timothy
MR
Sent: Tuesday, 24 October 2006 09:21
To: Trond Myklebust
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] fcntl(3, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET,
start=0,len=0}) unreasonably slow SEC: UNCLASSIFIED


Thanks! we put up 2.6.9-42 and the program now runs without the 30s
delays.

It is still quite slow though when two instances are contending for the
lock. As an example, tess does 1000 open-lock-close cycles in about 1
second. If two instances are running, a 1000 cycles takes 40 seconds!

cheers,
Tim

-----Original Message-----

Sorry about the quoting, I don't know how to make Outlook behave and my
employer makes it compulsory.

The above slowdown is observed when the server is a NetApp storage
device. When it is another linux box, no slowdown is observed.

cheers,
Tim

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
