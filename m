From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: mysterious NFS-behaviour
Date: Thu, 8 May 2003 10:56:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305081056.01105.bernd-schubert@web.de>
References: <03May8.101130cest.115214@gw.cae-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp01.web.de ([217.72.192.180] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DhAc-0003Av-00
	for <nfs@lists.sourceforge.net>; Thu, 08 May 2003 01:54:30 -0700
Received: from [217.185.93.81] (helo=hdlb-d9b95d51.pool.mediaWays.net)
	by smtp.web.de with asmtp (WEB.DE 4.98 #218)
	id 19DhAS-0006pB-00
	for nfs@lists.sourceforge.net; Thu, 08 May 2003 10:54:21 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <03May8.101130cest.115214@gw.cae-gmbh.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday 08 May 2003 10:17, Christoph Dohmen wrote:
> Hi folks,
>
> I was told about a very mysterious behaviour of a NFS-system. But I could
> not explain what's happening. So, maybe someone of this list is able?!
>
> Well, there's a system running suse linux 7.2 with kernel 2.4.4 on a

Have you ever been thought about upgrading your kernel ?

> nfs-server using software-raid for the exported directory. More than 60
> clients (also suse 7.2 with 2.4.4) mount this export.

Upgrade the clients as well.

> So the behaviour is the following:
> I have one client and open four terminales.
> In the first terminal (local) I do a mkdir foo in the mounted directory
> In the second terminal (local) I do a ls in the mounted directory and I get
> an I/O-error
> In the third terminal (ssh on the nfs-server) I can see the created
> directory. In the fourth terminal (ssh on another client) I can see the
> created directory after about one or two seconds.
>
> So, what's going on? Is there a misconfiguration? Are 60 clients too many??
>

2.4.4 is really old and many nfs- and other fs-fixes have been done since the 
release of this kernel version. Furthermore I think everything below 2.4.8 
can be considered as very buggy and shouldn't be used in a production 
environment.

Bernd




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
