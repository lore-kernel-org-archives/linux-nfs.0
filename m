From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS server not responding
Date: Thu, 04 Dec 2003 12:37:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCF70D9.1010808@RedHat.com>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de> <shsptfch1om.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARxPB-0004GU-WD
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 09:36:45 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARxPB-0002oJ-Cg
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 09:36:45 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id hB4Had221115
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 12:36:39 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4Hac206532
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 12:36:38 -0500
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4Hac313071
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 12:36:38 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <shsptfch1om.fsf@charged.uio.no>
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

Trond Myklebust wrote:

>Now it may be that the Fedora kernel has some other crap in it that is
>screwing up interrupts & other such things (NAPI perhaps?). Has
>anybody that is seeing these problems made a comparison with an
>equivalent stock Marcelo kernel?
>  
>
For the recored here is the "crap" that's in FC1 and not in the stock 
kernel:

 From Trond's Tree:
    linux-2.4.x-rdplus.dif
    linux-2.4.x-cto.dif
    linux-2.4.x-pathconf.dif

 From -ac1 tree:
    kmap() calls changed to kmap_atomic() calls
   
Patches posted to this list:
    linux-2.4.21-nfs-accesscache.patch - reduces the number of otw 
ACCESS calls
    linux-2.4.20-nfs-ia64-EIO.patch    - increase RPC_RTO_MIN to HZ/30

And here are the patches that are in the stock kernel
and not in FC1 (yet)...

# 03/10/11  trond.myklebust@fys.uio.no  1.1148.17.6
# Make the client act correctly if the RPC server's asserts
# that it does not support a given program, version or
# procedure call.

# 03/10/11  trond.myklebust@fys.uio.no  1.1148.17.1
# Fix a deadlock in the NFS asynchronous write code.

SteveD.




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
