From: Neil Brown <neilb@suse.de>
Subject: Re: Number of nfsd processes?
Date: Sun, 25 Jun 2006 19:42:26 +1000
Message-ID: <17566.23170.136301.392306@cse.unsw.edu.au>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuR8W-000495-2V
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 02:42:36 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FuR8V-00060k-OD
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 02:42:36 -0700
To: "Simon Matthews" <simon.d.matthews+nfs@gmail.com>
In-Reply-To: message from Simon Matthews on Saturday June 24
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

On Saturday June 24, simon.d.matthews+nfs@gmail.com wrote:
> I am running servers based on recent 2.6.x kernels.
> 
> I see "server timeout" messages from client machines running 2.4.x
> kernels (typically RedHat kernels). I have tried increasing the number
> of nfsd processes, but I seem to have got it up to absurd numbers (64
> processes).
> 
> I read somewhere that each client only makes one connection to the
> server, so one should not need more nfsd processes than clients, but
> when I look at the processes duing some heavy nfs access, I see more
> than one nfsd process taking significant  cpu time.

There may be only one connection, but lots of requests may be sent
without waiting for the reply to the previous one, so the server may
be handling multiple requests at once for the one client.

> 
> So, in a small network of say about 10 fast clients (with GigE
> connections), how many  is a reasonable number of nfsd processes?

Lots? 
Look in /proc/net/rpc/nfsd
Look at the line starting 'th'.
 The first number is the number of threads
 The second is the number of times the a thread has started handling
  a request when all other threads were busy
 The remainder are the number of seconds when
    0-10% of threads were in use
   10-20% of threads were in user
   20-30%
    ...
   90-100%

 From this you should be able to get an idea of how many threads
 are getting used.
 Ideally, the top few numbers should be very small compared with the
 earlier numbers.  If they are, increase the number of threads.
 I usually run with 128, but there are probably 100-200 clients, but
 they aren't very busy clients.

> Should I see I/O errors if there are not enough nfsd processes?

Only if you are using 'soft' mounts.  Don't ever use soft mounts.
(Well, they might be OK in some read-only situations....)
You could see lots of 
   nfs: server foo not responding, still trying
   ...
   nfs: server foo OK
messages if you don't have enough threads.

NeilBrown


> 
> Regards,
> Simon
> 
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
