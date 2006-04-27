From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Update: NFS over a Win2k Server NAT Router with "DMZ":
	nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 14:02:52 -0400
Message-ID: <1146160972.8101.12.camel@lade.trondhjem.org>
References: <005401c66a19$2a6f6d30$0200a8c0@novastorm>
	 <000401c66a21$154a8c70$0200a8c0@novastorm>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZApV-0006Zg-03
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:03:05 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FZApT-0001Vh-Cc
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:03:05 -0700
To: Michael Lackner <thrawn@xin.at>
In-Reply-To: <000401c66a21$154a8c70$0200a8c0@novastorm>
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

On Thu, 2006-04-27 at 19:36 +0200, Michael Lackner wrote:
> Greetings again.
> 
> A little update to the Situation as described in the mail before...
> 
> I now tried a "touch" on my NFS mounts, and to my surprise it worked. So i can
> even write to NFS mounted directories from within the private network. But i still
> cannot read...  
> 
> When mounting soft, i get input/output errors when trying ls, no matter what values i
> set timeo and retrans to..  I also tried different values for rsize, down to 1024. Doesn't
> work either..

If the problem is that READ and READDIR requests are getting lost, then
it might be due to your firewall nixing the UDP fragments (recall that
fragments don't have information about port numbers etc).

I'd suggest trying TCP instead.

Cheers,
  Trond



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
