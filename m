From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: EJUKEBOX and Java
Date: Wed, 03 Apr 2002 15:50:10 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAB7912.3080300@emageon.com>
References: <6440EA1A6AA1D5118C6900902745938E50CE34@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, "Kent, Ian I." <Ian.Kent@woodside.com.au>
Received: from [63.162.183.250] (helo=emgw2ksrv001.emgdom001.emageon.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16sse0-0000HQ-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Apr 2002 13:50:16 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Thanks, but that's not the case. The IBM JVM uses native threads as it 
should. We have recently discovered, however, that they apparently have 
signal handling problems that are leading to this deadlock. Our 
developers were able to write a small app that consistently reproduces 
the deadlock on both their 1.3.0 and 1.3.1 releases. We have not been 
able to reproduce the problem with Sun's JVM, thus the finger points to 
to the IBM JVM.


Lever, Charles wrote:

>this could appear because your Java threads are emulated
>entirely in user space (green threads?).  if one of the
>threads goes into the kernel via a system call and doesn't
>return, then your entire JVM is hung.
>
>just a thought.
>
>>-----Original Message-----
>>From: Brian Tinsley [mailto:btinsley@emageon.com]
>>Sent: Tuesday, April 02, 2002 7:39 PM
>>To: Kent, Ian I.
>>Cc: nfs@lists.sourceforge.net
>>Subject: Re: [NFS] EJUKEBOX and Java
>>
>>
>>Understood, but when the EJUKEBOX error is encountered by our 
>>application, the fact that RPC blocks signals (via rpc_clnt_sigmask) 
>>during this sleep seems to cause every thread in the Java VM to 
>>"deadlock" (we can even see the garbage collector stop) until data 
>>starts to stream back from the NFS server. This is our 
>>current working 
>>theory anyway.
>>
>>
>>Kent, Ian I. wrote:
>>
>>>The NFSv3 RFC specifies the client behaviour you are seeing 
>>>
>>for this server return.
>>
>>>It's not a deadlock, the client sleeps, then retries.
>>>
>>
>>
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>

-- 
Brian Tinsley
Senior Systems Engineer
Emageon





_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
