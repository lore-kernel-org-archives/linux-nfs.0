From: "Simon Matthews" <simon.d.matthews+nfs@gmail.com>
Subject: Number of nfsd processes?
Date: Sat, 24 Jun 2006 17:59:11 -0700
Message-ID: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuIy2-0004en-3M
	for nfs@lists.sourceforge.net; Sat, 24 Jun 2006 17:59:14 -0700
Received: from py-out-1112.google.com ([64.233.166.181])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FuIy1-0007zf-7F
	for nfs@lists.sourceforge.net; Sat, 24 Jun 2006 17:59:14 -0700
Received: by py-out-1112.google.com with SMTP id f28so1022153pyf
	for <nfs@lists.sourceforge.net>; Sat, 24 Jun 2006 17:59:11 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

I am running servers based on recent 2.6.x kernels.

I see "server timeout" messages from client machines running 2.4.x
kernels (typically RedHat kernels). I have tried increasing the number
of nfsd processes, but I seem to have got it up to absurd numbers (64
processes).

I read somewhere that each client only makes one connection to the
server, so one should not need more nfsd processes than clients, but
when I look at the processes duing some heavy nfs access, I see more
than one nfsd process taking significant  cpu time.

So, in a small network of say about 10 fast clients (with GigE
connections), how many  is a reasonable number of nfsd processes?
Should I see I/O errors if there are not enough nfsd processes?

Regards,
Simon

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
