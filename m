From: Peter Staubach <staubach@redhat.com>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 15:34:40 -0400
Message-ID: <42D6BE50.30804@redhat.com>
References: <20050714125536.788.qmail@web51609.mail.yahoo.com>	 <1121347282.8202.49.camel@lade.trondhjem.org> <1121368645.10126.193.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	mehta kiran <kiranmehta1981@yahoo.com>, nfs@lists.sourceforge.net,
	steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt9VD-0007OW-T5
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:36:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt9VC-0007cM-Fn
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:36:12 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1121368645.10126.193.camel@seki.nac.uci.edu>
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

Dan Stromberg wrote:

>On Thu, 2005-07-14 at 09:21 -0400, Trond Myklebust wrote:
>  
>
>>to den 14.07.2005 Klokka 05:55 (-0700) skreiv mehta kiran:
>>    
>>
>>>Hi , 
>>>        I have observed the following.
>>>        RHEL4 GA and U1 
>>>        client accesses filesystem exported
>>>        by server using nfsv4 .
>>>
>>>        It takes lock  on a file.
>>>        Other clients on "different" systems
>>>        get NFSERR_DENIED and they retry to acquire
>>>        lock.
>>>
>>>        When first client release lock , other client
>>>        gets the lock.
>>>        But when i see in /var/lib/nfs/statd/sm 
>>>        directory , i cannot see any file with
>>>        name = server's name.
>>>      
>>>
>>An NFSv4 client has no use for statd. The NFSv4 protocol has its own
>>methods for tracking client and server reboots.
>>    
>>
>
>lockd too, I hope?
>

Right!

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
