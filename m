From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Help with UDP NFS firewall rules
Date: Thu, 06 Jul 2006 13:06:47 -0400
Message-ID: <1152205607.6047.10.camel@lade.trondhjem.org>
References: <20060706165158.37943b1a.Ian.Grant@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyXJo-00030d-2B
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 10:07:12 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FyXJm-000249-0n
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 10:07:12 -0700
To: Ian Grant <Ian.Grant@cl.cam.ac.uk>
In-Reply-To: <20060706165158.37943b1a.Ian.Grant@cl.cam.ac.uk>
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

On Thu, 2006-07-06 at 16:51 +0100, Ian Grant wrote:
> Dear NFS people,
> 
> I am trying to access NFS services running on a 2.4.20 kernel, using UDP. The client is running SUSE 9.3 with kernel 2.6.11.4-21.12 and iptables acting as a firewall.
> 
> The problem is that the nfsd on the server sends UDP replies to random ports <1024 on the client. Is there a way to fix the port chosen on the client end so that I can make a hole in the firewall for it?
> 
> Ian Grant

That is unfortunately not possible at this time. Is there any reason why
you can't use TCP?

Cheers,
  Trond


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
