From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 13:10:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4130BC76.9070202@RedHat.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C16io-0001n7-F0
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:10:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C16in-0002Ke-VH
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:10:34 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <20040827233235.GB57703@brandon.dvalentine.com>
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



Brandon D. Valentine wrote:

>On Fri, Aug 27, 2004 at 05:51:30PM -0400, Trond Myklebust wrote:
>  
>
>>To be more specific, I believe the problem here is that you are using
>>an NFSv2-only kernel together with a version of mountd that is
>>advertising NFSv2 *and* NFSv3.
>>    
>>
>
>I would be very happy to find out that it was so simple, but it doesn't
>appear to be.  The problem definitely appears to be on the client
>system, not the server.
>
>  [root@scylla root]# rpcinfo -u reef nfs
>  program 100003 version 2 ready and waiting
>  [root@scylla root]# rpcinfo -u reef nfs 3
>  rpcinfo: RPC: Program/version mismatch; low version = 2, high version = 2
>  program 100003 version 3 is not available
>
>  reef:~# ps -Af | grep mountd
>  root       395     1  0 Aug17 ?        00:00:00 /usr/sbin/rpc.mountd --no-nfs-version 3
>  
>
Upgrade your nfs-utils to the latest rawhide version (nfs-utils-1.0.6-31 
I believe)
to see if it take care of the problem. I think this has to do with the 
order of
how mountd and rpc.imapd are started. Basically mountd has to be running
before rpc.idmapd  for things to work...  So in  the case of the server 
(where
rpc.idmapd is already started), the nfs startup script send rpc.idmapd a 
signal
telling it to reopen its nfsd files (i.e. files under /proc/fs/nfsd )

SteveD.



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
