From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 21:32:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4131323C.6060509@RedHat.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com> <4130BC76.9070202@RedHat.com> <20040828183847.GA84014@brandon.dvalentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1EYq-0004xi-03
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 18:32:48 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C1EYo-0005Hg-G3
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 18:32:47 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i7T1WjS0018517
	for <nfs@lists.sourceforge.net>; Sat, 28 Aug 2004 21:32:45 -0400
Received: from RedHat.com (vpn83-127.boston.redhat.com [172.16.83.127])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i7T1Wi320244
	for <nfs@lists.sourceforge.net>; Sat, 28 Aug 2004 21:32:44 -0400
In-Reply-To: <20040828183847.GA84014@brandon.dvalentine.com>
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



Brandon D. Valentine wrote

>In other words: what the heck are you talking about? =)
>  
>
 I thought  the problem was that rpc.mount was being
*unintentionally* started with the " -no-nfs-version  3"
flag which I was  happening in my testing of the nfs4 code
Something similar to:

root       395     1  0 Aug17 ?        00:00:00 /usr/sbin/rpc.mountd 
--no-nfs-version 3

But I guess I was mistaken......

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
