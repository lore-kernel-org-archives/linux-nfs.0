From: trond.myklebust@fys.uio.no
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Tue, 2 Mar 2004 01:49:49 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2005.207.214.87.84.1078188589.squirrel@webmail.uio.no>
References: <Pine.LNX.4.44.0403011907010.10276-100000@kenzo.iwr.uni-heidelberg.de>
    <35345.207.214.87.84.1078167489.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Shantanu Goel" <Shantanu.Goel@lehman.com>,
     "Shantanu Goel" <sgoel01@yahoo.com>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxyBM-0008Nf-8R
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 16:54:48 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxxpM-0003BK-Uh
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 16:32:05 -0800
To: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <35345.207.214.87.84.1078167489.squirrel@webmail.uio.no>
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

På må , 01/03/2004 klokka 10:58, skreiv trondmy@ulrik.uio.no:

> I'm currently working on a scheme for throttling processes that keep on
> scheduling new writes while the VM is trying to free up memory.


OK... This is now ready for testing as part of the latest NFS4_ALL patch. See

http://www.fys.uio.no/~trondmy/src/Linux-2.6.x/2.6.3/linux-2.6.3-22-congestion.dif

Cheers,
  Trond



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
