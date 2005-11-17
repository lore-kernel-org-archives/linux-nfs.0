From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Funny looking code in __rpc_purge_upcall
Date: Thu, 17 Nov 2005 11:01:00 -0500
Message-ID: <437CA93C.7030402@RedHat.com>
References: <437BD49A.5070509@google.com> <1132197000.8561.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcmCa-0005il-AB
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:01:32 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EcmCa-0002Yy-4v
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:01:32 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id jAHG11AX026568
	for <nfs@lists.sourceforge.net>; Thu, 17 Nov 2005 11:01:01 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id jAHG11V17259
	for <nfs@lists.sourceforge.net>; Thu, 17 Nov 2005 11:01:01 -0500
Received: from [172.16.80.110] (dickson.boston.redhat.com [172.16.80.110])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id jAHG10425573
	for <nfs@lists.sourceforge.net>; Thu, 17 Nov 2005 11:01:00 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <1132197000.8561.1.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> That might explain the rpc-pipe related cleanup problem that Steve
> Dickson has reported on the list earlier...
No go... :-( I just tried that patch and unfortunately it does
not stop the oops that you are referring to...

steved.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
