From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 12:08:39 -0400
Message-ID: <EXNANE01hjJ8uT6Ssuo00000243@exnane01.hq.netapp.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
	<1188573228.6649.100.camel@heimdal.trondhjem.org>
	<46D835F4.4030703@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR93F-0003KE-Qa
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:08:56 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IR93K-0001Nv-3j
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:08:58 -0700
In-Reply-To: <46D835F4.4030703@oracle.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
	<1188573228.6649.100.camel@heimdal.trondhjem.org>
	<46D835F4.4030703@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I'll change the strings to whatever representation folks want. All I did
was move 'em!

Repies to earlier comments:

"fixes an omission": sounds good.

"RPCB_" prefix: They're (with this patch) part of the rpcbind api. The prefix
seems logical to me... when you say "the same as the other RPC..." do you
mean they should be "RPC_NETID_..."?

RPCB_MAXNETIDLEN: Sure, I'll move it. It is, after all, a limit on the string
passed as the netid, i.e. part of the API. But let me ask this. It really isn't
necessary, the code in rpcbind can easily accommodate longer strings. Is
it worth coding the extra generality? The reason I didn't is because (as the
comment mentions) there aren't any longer strings defined by any RFC.

clnt.h vs msg_prot.h: After discovering the rpcbind calls defined in clnt.h,
and also seeing rpc goop in there, it felt more correct than msg_prot.h,
which is pretty much about rpc marshaling and error codes. All the other
rpcbind stuff is in clnt.h, and most all clnt's need to call rpcbind to find
their port. That's my rationale.

Tom.


At 11:38 AM 8/31/2007, Chuck Lever wrote:
>Trond Myklebust wrote:
>> On Fri, 2007-08-31 at 10:30 -0400, Chuck Lever wrote:
>>> Trond Myklebust wrote:
>>>> On Fri, 2007-08-31 at 10:08 -0400, Chuck Lever wrote:
>>>>
>>>>>>  
>>>>>> +/*
>>>>>> + * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
>>>>>> + */
>>>>>> +#define	RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
>>>>>> +#define	RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
>>>>>> +#define	RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
>>>>>> +#define	RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
>>>> BTW: Any reason why we are using escaped octal instead of plain ascii
>>>> here?
>>> Is there a guarantee that these C strings will be US-ASCII on *every* 
>>> platform in every locale on which Linux kernels are built?  Z-series, 
>>> for example?
>>>
>>> If yes, then we can use a normal string.
>
>> You might have somebody convert all the strings in the kernel into
>> EBCDIC, just for fun, but that will make the strings unreadable on the
>> computer running the resulting kernel ('cos Linux uses ASCII) and would
>> likely break all sorts of kernel-userspace interfaces besides breaking
>> this little snippet in the rpcbind code.
>
>Well, according to Harbison & Steele, the C source and eventual 
>execution character set can be different.  I'm not as certain as you are 
>of the guarantee that the Linux kernel environment is US-ASCII on every 
>platform from compile to execution.  I've actually written C system 
>programs in OpenEdition on MVS/390.
>
>However, if you are comfortable using just a plain old C string (and 
>maybe keeping documentation of the US-ASCII requirement in a comment), 
>have Tom replace the octal strings with C character strings in his patch.
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
