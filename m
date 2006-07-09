From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Number of nfsd processes?
Date: Sat, 8 Jul 2006 22:54:02 -0400
Message-ID: <20060709025401.GA14393@fieldses.org>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
	<17566.23170.136301.392306@cse.unsw.edu.au>
	<1151242251.23280.5.camel@pc>
	<40b437200606251313t649fc76agd352e88c9a2bd252@mail.gmail.com>
	<17567.34607.910187.634995@cse.unsw.edu.au>
	<17584.15326.473593.2056@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FzPQs-00010J-1Q
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 19:54:06 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FzPQs-0005CP-6Q
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 19:54:06 -0700
To: Carlos Carvalho <carlos@fisica.ufpr.br>
In-Reply-To: <17584.15326.473593.2056@fisica.ufpr.br>
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

On Sat, Jul 08, 2006 at 08:12:30PM -0300, Carlos Carvalho wrote:
> Here are numbers from two servers:
> 
> th 8 513564 30829.484 1478.308 980.596 0.000 518.840 344.688 274.164
> 222.180 0.000 1613.580
> 
> th 8 28805553 21105.748 2502.784 2370.796 0.000 5226.212 2500.644
> 2579.308 3348.104 0.000 22526.404
> 
> According to Neils instructions I should increase the number of
> threads in both of them because the last value is significant compared
> to the previous ones, particularly in the second case. However what do
> the zeros mean? They appear in both servers that run 2.6.16.22.

They're totally unimportant; ignore them.

(The long version: it reports the amount of time that 10%, 20%, ...,
100% of the threads are busy.  You've only got 8 threads, so that's 8
values to stick in 10 slots, so a couple slots always end up empty.)

--b.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
