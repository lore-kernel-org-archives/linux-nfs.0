From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Thu, 15 May 2003 10:10:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC39FDF.60609@RedHat.com>
References: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GJRq-0003w4-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 07:11:07 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


It appears the RTO code does seem to be working but when the
minimums start so low (like at 4m instead 40ms) it takes some
time for the timeout value to build up and with soft mounts
there is no time...

Maybe I'm missing something... increasing the timeout value should
not have any affect on performance since in a well tuned
client and server these timeout will never occur since the
responses from the server will be returned before the
timeout expires... right? Also decreasing the number of timeouts
will decrease the number of retransmits which is another good
thing... True?

SteveD.

Lever, Charles wrote:

>steve-
> 
>i think there must be an underlying problem here.  soft mounts
>to slow servers should work correctly without raising the RTO
>minimum.  
> 
>the RTO estimator should automatically raise the RTO values to
>avoid extra timeouts.  if not, there is a problem with the RTO
>estimator that needs to be addressed.
> 
>
>-----Original Message----- 
>From: Steve Dickson [mailto:SteveD@RedHat.com] 
>Sent: Wed 5/14/2003 8:34 PM 
>To: Trond Myklebust; nfs@lists.sourceforge.net 
>Cc: 
>Subject: Re: [NFS] [PATCH] Timeouts gone wild on ia64
>
>
>
>Hi Trond, 
>
>Trond Myklebust wrote: 
>
>  
>
>>>>>>>" " == Steve Dickson <SteveD@RedHat.com> writes: 
>>>>>>>           
>>>>>>>
>>>>>>>              
>>>>>>>
>>    > What this patch does is make the minimal Round Trip time value 
>>    > relative to HZ. So When HZ is greater (as in the case of ia64) 
>>    > the minimal value goes up. 
>>    >  Comments? 
>>
>>1/30 of a second is a long time. Why that particular choice? 
>>
>>Note: "It works" won't cut ice as that is completely a function of the 
>>choice of hardware. 
>>
>>    
>>
>I realize this but... I figured waiting a few extra ticks of time before 
>timing 
>out was probably a good thing with respect to soft mounts to slow 
>servers... 
>Especially  since EIO errors can be pretty disruptive... 
>
>And as I see, its a no-op with a fast (or slow) client  talking to a fast 
>server because the timeout will should never happen... (i.e. the waiting 
>thread will get the response before the time out occurs).... 
>
>SteveD. 
>
>
>
>
>
>------------------------------------------------------- 
>Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara 
>The only event dedicated to issues related to Linux enterprise solutions 
>www.enterpriselinuxforum.com 
>
>_______________________________________________ 
>NFS maillist  -  NFS@lists.sourceforge.net 
>https://lists.sourceforge.net/lists/listinfo/nfs 
>
>  
>



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
