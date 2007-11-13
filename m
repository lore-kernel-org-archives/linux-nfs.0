From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Differences between 2.6.5 und 2.6.16: getattr
	with	actimeo=0 and O_DIRECT
Date: Tue, 13 Nov 2007 11:09:31 -0500
Message-ID: <E3DC25F2-9870-4CAF-9F4E-938070A3060A@oracle.com>
References: <4739686E.8080501@googlemail.com>
	<1194960598.7468.11.camel@heimdal.trondhjem.org>
	<4739C901.1020404@googlemail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Gerd Bavendiek <gerd.bavendiek@googlemail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IryLT-0008CY-E5
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 08:10:35 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IryLX-00008J-MQ
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 08:10:41 -0800
In-Reply-To: <4739C901.1020404@googlemail.com>
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


On Nov 13, 2007, at 10:55 AM, Gerd Bavendiek wrote:

> Trond Myklebust schrieb:
>> On Tue, 2007-11-13 at 10:03 +0100, Gerd Bavendiek wrote:
>>> Hi,
>>>
>>> analyzing performance issues with Oracle databases on an NFS client
>>> running on SLES9 SP3 and NetApp as NFS server, I found that in SLES9
>>> SP3 each write call is followed by an getattr. This is not the case
>>> with SLES10 SP1.
>>>
>>> Mount options in use are:
>>>
>>> rw,v3,rsize=32768,wsize=32768,acregmin=0,acregmax=0,acdirmin=0,acdir 
>>> max=0,hard,lock,proto=tcp,addr=172.18.131.134
>>>
>>> I do
>>>
>>> dd if=/dev/zero of=/mnt/qqq oflag=direct bs=8k count=100000
>>>
>>> and using tcpdump (BTW, is there an easier way ?) I see with  
>>> SLES9 SP3
>>> (i.e. 2.6.5-7.244) each single 8k write followed by an getattr  
>>> (which
>>> comes at some cost).
>>>
>>> Using SLES10 SP1 (2.6.16.46-0.12) there is only one getattr when dd
>>> closes the file.
>>>
>>> Is there anything I can do to avoid the getattr calls in SLES9 SP3
>>> (no, sorry, can't update to SLES10 SP1) ?
>>
>> For one thing, you could turn attribute caching back on. I don't know
>> why SLES10 fails to GETATTR, but acregmin=0,acregmax=0 turns  
>> attribute
>> caching off. Append writes need to know where the end-of-file is,  
>> and so
>> they will force a GETATTR when there is no attribute caching.

Note "oflag=direct".

>> Trond
>>
>>
>
> Trond,
>
> you say: SLES10 fails to GETATTR.
>
> So with acregmin=0,acregmax=0 etc. we should always have one write AND
> one getattr ?
>
> So SLES9 SP3 does it the right way ?
>
> Gerd

SLES 9's direct I/O engine does the GETATTRs.  There's no way to get  
rid of that behavior in that kernel version; it's an implementation  
limitation that was corrected in later versions.

SLES 10's direct I/O engine is more advanced, and doesn't do GETATTRs  
with direct I/O.

When performing direct I/O, the client doesn't need to know how large  
the file is.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
