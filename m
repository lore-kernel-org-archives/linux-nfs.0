From: "Michael Lackner" <thrawn@xin.at>
Subject: Re: Update: NFS over a Win2k Server NAT Router with "DMZ":nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 20:16:10 +0200
Message-ID: <001101c66a26$adfb58f0$0200a8c0@novastorm>
References: <005401c66a19$2a6f6d30$0200a8c0@novastorm> <000401c66a21$154a8c70$0200a8c0@novastorm> <1146160972.8101.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZB2X-0007yy-Aj
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:16:33 -0700
Received: from 83-64-254-60.bruck-mur.xdsl-line.inode.at ([83.64.254.60] helo=xin.at)
	by mail.sourceforge.net with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.44)
	id 1FZB2T-0005f0-K7
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:16:33 -0700
Received: from novastorm by xin.at
	(MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50000005499.msg
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 20:16:12 +0200
To: <nfs@lists.sourceforge.net>
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

Hello!

> On Thu, 2006-04-27 at 19:36 +0200, Michael Lackner wrote:
>> Greetings again.
>> 
>> A little update to the Situation as described in the mail before...
>> 
>> I now tried a "touch" on my NFS mounts, and to my surprise it worked. So i can
>> even write to NFS mounted directories from within the private network. But i still
>> cannot read...  
>> 
>> When mounting soft, i get input/output errors when trying ls, no matter what values i
>> set timeo and retrans to..  I also tried different values for rsize, down to 1024. Doesn't
>> work either..
> 
> If the problem is that READ and READDIR requests are getting lost, then
> it might be due to your firewall nixing the UDP fragments (recall that
> fragments don't have information about port numbers etc).
> 
> I'd suggest trying TCP instead.

Strangely, i can read/write directories from the newer "testserver" without problems
even when using nfsver=2 and udp options.

I'm afraid, the nfs server on "fileserver" doesn't even support tcp. There should be
experimental tcp support for nfs in kernel 2.4.20 already, but i don't know if this 
feature is activated in RH9. How can i check if my nfs server supports tcp and how 
can i activate tcp, if so? By default, nfsd runs only on udp on that machine.

Thanks very much.

Best Regards
Michael Lackner
University of Leoben
Chair for Information Technology, IT Administration



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
