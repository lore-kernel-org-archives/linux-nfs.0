From: "work-usenet@nouce.net" <work-usenet@nouce.net>
Subject: Questiong regarding change in support for > 256 outstanding read/write
 operations per mount point for linux clients
Date: Wed, 09 Jun 2004 09:10:41 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40C70C50.7030105@nouce.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY2qs-0000G7-By
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 06:10:46 -0700
Received: from [208.234.30.51] (helo=aitcom.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY2qr-0000e8-KJ
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 06:10:45 -0700
Received: from nouce.net (fay-gateway.aitcom.net [208.234.1.225])
	by aitcom.net (8.12.10/8.12.10) with ESMTP id i59CsUmB011300
	for <nfs@lists.sourceforge.net>; Wed, 9 Jun 2004 08:54:31 -0400
To: nfs@lists.sourceforge.net
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

*Is there a backpatch to allow this change in a 2.4 kernel and/or has 
this been added to the 2.6 client? As I use NFS on 2.4 based Linux 
systems. But would like to see if this client change would help 
performance problems I'm seeing with clients connecting to an Netapp 
filer. Thanks.



B7. I have achieved pretty fast speeds in some client benchmarks, but 
when my client is heavily loaded, it slows down considerably. Why does 
that happen? *

    *A.* The Linux client limits the total number of pending read or
    write operations per mount point. This prevents the client from
    exhausting its memory with cached read or write requests when the
    network or server is slow. The hard limit is 256 outstanding read or
    write operations per mount point. When that limit is reached, the
    client does not issue a new read or write operation until at least
    one outstanding read or write operation completes, thus serializing
    all reads and writes on that mount point until load is reduced.

    Two ways of mitigating this effect are to:

       1.

          Increase rsize and wsize on your client's mount points. This
          increases the amount of data that can be involved in
          outstanding reads or writes at any given time.

       2.

          Mount the same server partition multiple times on your
          clients, and spread your applications among the mount points.

    This limit has been removed in the 2.5 NFS client (after 2.5.47).



-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
