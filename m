From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
 kernel
Date: Thu, 13 Jan 2005 09:01:28 -0500
Message-ID: <41E67F38.6060203@RedHat.com>
References: <41DD8403.7030601@RedHat.com>	 <1105118040.10979.70.camel@lade.trondhjem.org>	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>	 <41E43DE1.5080703@RedHat.com>	 <1105480745.11430.56.camel@lade.trondhjem.org> <41E569E3.20206@RedHat.com>	 <1105554342.23943.1.camel@lade.trondhjem.org> <41E5767F.40204@RedHat.com> <1105576681.14443.100.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cp5Xt-00066m-Vn
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 06:01:53 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cp5Xt-00035t-K3
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 06:01:54 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105576681.14443.100.camel@lade.trondhjem.org>
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

>on den 12.01.2005 Klokka 14:11 (-0500) skreiv Steve Dickson:
>
>  
>
>>Here is what I found.... just adding the PF_DUMPCORE rpc_clnt_sigmask() 
>>no core was dropped
>>because __rpc_execute returned -ERESTARTSYS due to signalled() == TRUE.
>>
>>When I added back the  PF_DUMPCORE check to __rpc_execute(), only the 
>>header of the core
>>was dropped  because nfs_wait_event() returned -ERESTARTSYS because 
>>signalled() == TRUE.
>>
>>When I added back the PF_DUMPCORE to nfs_wait_event(), the entire core 
>>was dropped.
>>
>>So it appears to me that you need both checks.....
>>    
>>
>
>No! Those extra checks are neither necessary, nor are they even correct!
>I repeat what I said in my earlier mail:
>
>        - The change to nfs_wait_event() converts it into an
>        unconditional uninterruptible sleep. That means you can never
>        "kill -9" out of waiting for the core dump to finish in case the
>        server crashes!
>  
>
By adding the PF_DUMPCORE check to rpc_clnt_sigmask() (as you suggested)
I thought I had taken care of this problem... but now I realize the 
check in nfs_wait_event()
is the real issue... sorry for making you swing that clue bat twice!! :)

>        - The loop you add to __rpc_execute() is pointless: The signal
>        that caused your process to wake up is neither cleared nor
>        masked, so when it later tries to block (such as when waiting
>        for a reply from the server), that process will just find itself
>        immediately woken up again by the same signal.
>  
>
I do understand this point.... and I *thought* I had addressed it by 
making __rpc_execute()
temporary ignoring  signals and having nfs_wait_event () call  
wait_event() instead
of  wait_event_interruptible().....


>As for myself, I'm getting full coredumps when I apply the 2 line patch
>I sent you. The appended testcase works every time:
>  
>
hmm.... something is amiss.... because I'm definitely not see this.... 
but I'll keep digging...

thanks!

steved.






-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
