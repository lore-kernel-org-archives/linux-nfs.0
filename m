From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] Re: [PATCH 0/4 Revised] NLM - lock
	failover
Date: Wed, 25 Apr 2007 11:39:24 -0400
Message-ID: <462F762C.6000106@redhat.com>
References: <OFABDC8A62.05BC8A30-ON882572C8.00541812-882572C8.00545C53@us.ibm.com>
	<462F718C.9060201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: cluster-devel@redhat.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgjvB-0000R7-Cu
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 09:00:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgjvD-0002q5-Nl
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 09:00:48 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3PG0fNc010104
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 12:00:41 -0400
In-Reply-To: <462F718C.9060201@redhat.com>
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

Wendy Cheng wrote:
> Marc Eshel wrote:
>>> The detailed overall steps were described in the first email we sent 
>>> *long* time (> 6 months, I think) ago. The first step of the whole 
>>> process is tearing down the floating IP from the failover server. 
>>> The IP is not accessible until filesystem is safely fail-over and 
>>> SM_NOTIFY ready to be sent.
>>
>> I thought this is a solution for an active active server where a 
>> cluster file system can export the same file system from multiple NFS 
>> servers.
>> Marc.
>>
>
> Yes ... but remember we should have two cases here:
>
> 1) Local filesystems such as ext3 - both IP and filesystem are not 
> accessible during the transition.
> 2) Cluster filesystem such as GFS or GPFS - filesystem may still be 
> accessible (depending on the configuration, say you have advertised 
> two exported IP addresses, each serving different subdirectories for 
> the very same cluster filesystem). The failover IP should be suspended 
> during the transition until SM_NOTIFY is ready to go out (but the 
> other IP should be up and services the requests as it should).
>
> I assume people understand that the affected export entries should 
> have been un-exported (as part of the over-all process).

To remind people, we had described the overall steps in the first round 
of kernel interface discussions submitted to nfs mailing list (before 
implemented the code). These steps included un-export the entries, 
tearing down the IP, filesystem migration, SM_NOTIFY, grace period, etc. 
I'm in the middle of redoing the write-up. It will be uploaded into 
somewhere soon.

-- Wendy


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
