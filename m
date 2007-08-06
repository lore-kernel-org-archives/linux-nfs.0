From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 06 Aug 2007 15:16:28 -0400
Message-ID: <46B7738C.4020503@oracle.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEDD@exchrdm.ad.xensource.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040909080606070901000405"
Cc: nfs@lists.sourceforge.net
To: Wim Colgate <Wim.Colgate@xensource.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II85t-0005h5-C7
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:18:23 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II85v-0005or-8X
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:18:23 -0700
In-Reply-To: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEDD@exchrdm.ad.xensource.com>
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

This is a multi-part message in MIME format.
--------------040909080606070901000405
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Wim Colgate wrote:
> Specifically I am trying to inject errors by manually (but politely)
> bringing the NFS server down then up, then down (rinse and repeat ...)
> while doing IO from a linux client. As mentioned the open file is
> O_DIRECT and O_SYNC -- which I thought should mean either the data hits
> the server's storage or I should get an error; and I'm more than happy
> to deal with an IO error.
> 
> I'm confident the writes are less than wsize (4096 bytes to be precise).
> 
> 
> Is there a 100% guaranteed method to get the behavior I thought O_DIRECT
> and O_SYNC was providing?

What behavior did you expect O_DIRECT + O_SYNC to provide?  O_DIRECT 
means "don't cache data" and O_SYNC means "make sure the data is flushed 
to the server's disk before each write() system call returns." 
Technically, you don't need NFS_FILE_SYNC writes to do either of those.

Which kernel are you testing?  The client's use of NFS_FILE_SYNC writes 
changed over time.

> -----Original Message-----
> From: Peter Staubach [mailto:staubach@redhat.com] 
> Sent: Monday, August 06, 2007 10:33 AM
> To: chuck.lever@oracle.com
> Cc: Wim Colgate; nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS_UNSTABLE vs. FILE and DATA sync.
> 
> Chuck Lever wrote:
>> Wim Colgate wrote:
>>> If I have a soft mount, and open a file with O_DIRECT and O_SYNC, 
>>> should I ever expect a callback (nfs_writeback_done) with a 
>>> successful task->tk_status (i.e >= 0) with the committed state 
>>> (resp->verf->committed) set to NFS_UNSTABLE?
>> Yes, this can happen if the server decides to return NFS_UNSTABLE. 
>> Rare, but possible.
>>
>>> A secondary question: if the above is expected, does this occur 
>>> because someone is caching the write and is there a mechanism to 
>>> disable this effect?
>> Servers can return NFS_UNSTABLE to any WRITE request, so I can't think
> 
>> of a way this might be disabled. 
> 
> Actually, it would be a protocol error for a server to return
> a commitment level less than was requested by the client.  The
> server can return a greater commitment level, but not less than.
> 
>        ps

--------------040909080606070901000405
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------040909080606070901000405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040909080606070901000405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040909080606070901000405--
