From: carlos@fisica.ufpr.br (Carlos Carvalho)
Subject: Re: Number of nfsd processes?
Date: Sat, 8 Jul 2006 20:12:30 -0300
Message-ID: <17584.15326.473593.2056@fisica.ufpr.br>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
	<17566.23170.136301.392306@cse.unsw.edu.au>
	<1151242251.23280.5.camel@pc>
	<40b437200606251313t649fc76agd352e88c9a2bd252@mail.gmail.com>
	<17567.34607.910187.634995@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FzLyW-0000jm-Qr
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 16:12:37 -0700
Received: from fisica.ufpr.br ([200.17.209.129])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FzLyV-0003BP-RO
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 16:12:37 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <17567.34607.910187.634995@cse.unsw.edu.au>
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

Here are numbers from two servers:

th 8 513564 30829.484 1478.308 980.596 0.000 518.840 344.688 274.164
222.180 0.000 1613.580

th 8 28805553 21105.748 2502.784 2370.796 0.000 5226.212 2500.644
2579.308 3348.104 0.000 22526.404

According to Neils instructions I should increase the number of
threads in both of them because the last value is significant compared
to the previous ones, particularly in the second case. However what do
the zeros mean? They appear in both servers that run 2.6.16.22.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
