From: Neil Horman <nhorman@redhat.com>
Subject: Re: NFS response time
Date: Tue, 25 Jan 2005 16:43:50 -0500
Message-ID: <41F6BD96.4040409@redhat.com>
References: <003a01c50326$73182550$7889b38b@alpin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtYTf-0000RQ-RL
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 13:43:59 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtYTe-0001UJ-CZ
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 13:43:59 -0800
To: Duv Dek <onur@ee.bilkent.edu.tr>
In-Reply-To: <003a01c50326$73182550$7889b38b@alpin>
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

Duv Dek wrote:
> Hi
>  
> We have a problem with our NFS server on Redhat 9. In case a program on 
> the server uses high CPU, the NFS clients almost lock and nfs stops 
> giving response until that program lowers its CPU usage.  We tried to 
> increase the priority of nfsd deamons with renice, and also tried to 
> increase the number of nfsd threads, decreased the priority of the 
> program using high CPU with renice, but none of them worked. How can 
> we solve this problem so that nfs does not lock?
>  
Have your tried to ascertain which process on your system is responsible 
(or most responsible) for the high CPU utilization?

Neil

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
