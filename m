From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: Re: nfsd: terminating on error 104 problem
Date: Fri, 05 Mar 2004 18:01:58 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4048C096.3090803@framestore-cfc.com>
References: <404707BE.9070401@framestore-cfc.com> <20040304111138.GO22726@suse.de> <40472842.8030602@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AzJm7-0007c0-Tl
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 10:10:19 -0800
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AzJfX-000864-4Z
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 10:03:31 -0800
To: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
In-Reply-To: <40472842.8030602@framestore-cfc.com>
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

I tried out the patch today, rebooted with the new kernel at 9:42am

Then, we started getting these messages (which we were having before but 
didn't cause any noticable problems)

Mar  5 10:05:00 ps30 kernel: nfsd: peername failed (err 107)!

After a few hours, we started getting the terminating on error 104 errors:

Mar  5 13:56:49 ps30 kernel: nfsd: terminating on error 104

Until finally the server crashed, refusing input from the console. There 
were no messages on the console apart from the above nfsd errors. This 
is the last syslog entry

Mar  5 17:10:10 ps30 rpc.mountd: Caught signal 15, un-registering and 
exiting.
Mar  5 17:10:10 ps30 nfs: rpc.mountd shutdown succeeded

While the server was up we recieved 112 peername failed (err 107) 
messages, and 5 terminating on error 104 messages.

If you want any more info please tell me what it is you need.

Otherwise have a good weekend!

Thanks,
Johan.

Johan van den Dorpe wrote:
> Olaf Kirch wrote:
> 
>> On Thu, Mar 04, 2004 at 10:41:02AM +0000, Johan van den Dorpe wrote:
>>
>>> So from my limited knowledge of the kernel source I can see that 
>>> "terminating on error 104" corresponds to line 221 of
>>> /usr/src/linux-2.4.25/fs/nfsd/nfssvc.c. So svc_recv on line 191 is 
>>> obviously returning -104.
>>
>>
>>
>> 104 is ECONNRESET, this means the client reset the connection.
>> The server should really clean up the socket in this case.
>>
>> Does the attached patch help?
>> Beware - totally untested, better not try this on a production
>> machine :)
> 
> 
> Thanks very much for this... I'm going to run a test with this patch and 
> get back to you with results after.
> 
> 


-- 
Johan van den Dorpe


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
