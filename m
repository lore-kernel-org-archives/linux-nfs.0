From: Ian Grant <Ian.Grant@cl.cam.ac.uk>
Subject: Re: Help with UDP NFS firewall rules
Date: Fri, 7 Jul 2006 11:49:22 +0100
Message-ID: <B506885E-92CE-46D8-95DB-A443F1481531@cl.cam.ac.uk>
References: <20060706165158.37943b1a.Ian.Grant@cl.cam.ac.uk>
	<1152205607.6047.10.camel@lade.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fyntx-0000fU-3N
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 03:49:37 -0700
Received: from ppsw-0.csi.cam.ac.uk ([131.111.8.130])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fyntw-0003gy-6C
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 03:49:37 -0700
In-Reply-To: <1152205607.6047.10.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


On 6 Jul 2006, at 18:06, Trond Myklebust wrote:

> On Thu, 2006-07-06 at 16:51 +0100, Ian Grant wrote:
>> Dear NFS people,
>>
>> I am trying to access NFS services running on a 2.4.20 kernel,  
>> using UDP. The client is running SUSE 9.3 with kernel  
>> 2.6.11.4-21.12 and iptables acting as a firewall.
>>
>> The problem is that the nfsd on the server sends UDP replies to  
>> random ports <1024 on the client. Is there a way to fix the port  
>> chosen on the client end so that I can make a hole in the firewall  
>> for it?
>>
>> Ian Grant
>
> That is unfortunately not possible at this time. Is there any  
> reason why
> you can't use TCP?

Hi Trond,

Thanks. TCP doesn't work because the server host is multi-homed and  
the NFS server is using the wrong source IP address which defeats the  
iptables TCP connection tracking in the client.

I have just opened up the client to all UDP from port 2049 on the  
server and this is OK for now.

Cheers
Ian


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
