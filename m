From: Steve Dickson <SteveD@redhat.com>
Subject: Re: interprtation of /proc/net/rpc/nfsd
Date: Tue, 12 Oct 2004 05:05:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416B9E68.40009@RedHat.com>
References: <482A3FA0050D21419C269D13989C61130435E96A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHIck-0007sc-RS
	for nfs@lists.sourceforge.net; Tue, 12 Oct 2004 02:07:14 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CHIbY-0006WX-TZ
	for nfs@lists.sourceforge.net; Tue, 12 Oct 2004 02:07:14 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.10) with ESMTP id i9C95nvO022196
	for <nfs@lists.sourceforge.net>; Tue, 12 Oct 2004 05:05:49 -0400
Received: from RedHat.com (vpn83-137.boston.redhat.com [172.16.83.137])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i9C95hr14412
	for <nfs@lists.sourceforge.net>; Tue, 12 Oct 2004 05:05:44 -0400
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E96A@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:

>>Well... zeroing out the nfs stats was something I proposed a 
>>while ago but got shoot down both internally and externally 
>>since zero out stats is "not the Linux way".... so I've taken 
>>the patch out of both FC and RHEL kernels, but I guess I 
>>forgot to take it out of the nfs-utils....
>>    
>>
>
>for the record, the reason that zeroing the kernel stats is a bad idea
>is that this should really be a user-space thing.  otherwise, if process
>A is sampling the stats and process B zeroes them, it will screw up
>process A's samples.
>  
>
This make senses for stats that measure time based things like bit rate or
latency.... but for stats that measure simple activity, sampling does not
really come into play.... imho...

SteveD.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
