From: Gerd Bavendiek <gerd.bavendiek@googlemail.com>
Subject: Re: Differences between 2.6.5 und 2.6.16: getattr
 with	actimeo=0 and O_DIRECT
Date: Tue, 13 Nov 2007 16:55:45 +0100
Message-ID: <4739C901.1020404@googlemail.com>
References: <4739686E.8080501@googlemail.com>
	<1194960598.7468.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iry7C-0006TP-LK
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 07:55:50 -0800
Received: from mu-out-0910.google.com ([209.85.134.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iry7H-0001fD-W7
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 07:55:56 -0800
Received: by mu-out-0910.google.com with SMTP id i2so2699201mue
	for <nfs@lists.sourceforge.net>; Tue, 13 Nov 2007 07:55:53 -0800 (PST)
In-Reply-To: <1194960598.7468.11.camel@heimdal.trondhjem.org>
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

Trond Myklebust schrieb:
> On Tue, 2007-11-13 at 10:03 +0100, Gerd Bavendiek wrote:
>> Hi,
>>
>> analyzing performance issues with Oracle databases on an NFS client
>> running on SLES9 SP3 and NetApp as NFS server, I found that in SLES9
>> SP3 each write call is followed by an getattr. This is not the case
>> with SLES10 SP1.
>>
>> Mount options in use are:
>>
>> rw,v3,rsize=32768,wsize=32768,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,lock,proto=tcp,addr=172.18.131.134
>>
>> I do
>>
>> dd if=/dev/zero of=/mnt/qqq oflag=direct bs=8k count=100000
>>
>> and using tcpdump (BTW, is there an easier way ?) I see with SLES9 SP3
>> (i.e. 2.6.5-7.244) each single 8k write followed by an getattr (which
>> comes at some cost).
>>
>> Using SLES10 SP1 (2.6.16.46-0.12) there is only one getattr when dd
>> closes the file.
>>
>> Is there anything I can do to avoid the getattr calls in SLES9 SP3
>> (no, sorry, can't update to SLES10 SP1) ?
> 
> For one thing, you could turn attribute caching back on. I don't know
> why SLES10 fails to GETATTR, but acregmin=0,acregmax=0 turns attribute
> caching off. Append writes need to know where the end-of-file is, and so
> they will force a GETATTR when there is no attribute caching.
> 
> Trond
> 
> 

Trond,

you say: SLES10 fails to GETATTR.

So with acregmin=0,acregmax=0 etc. we should always have one write AND 
one getattr ?

So SLES9 SP3 does it the right way ?

Gerd

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
