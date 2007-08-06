From: "Wim Colgate" <Wim.Colgate@xensource.com>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 6 Aug 2007 12:33:27 -0700
Message-ID: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BF1D@exchrdm.ad.xensource.com>
References: <46B7738C.4020503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II8LR-0007V3-Aj
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:34:25 -0700
Received: from webmailrdm.xensource.com ([66.228.214.202])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II8LV-0001Yb-7Z
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:34:29 -0700
In-Reply-To: <46B7738C.4020503@oracle.com>
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

Hi Chuck,

The linux kernel I was using is 2.6.18-8.

To be fair, I was not trying to force NFS_FILE_SYNC; to make a long
story short, I started with O_DIRECT (please don't cache data). I moved
to add O_SYNC (don't return until my data is written safely). And when I
couldn't explain why I was missing some data (discrepancy between client
and server), I started investigating what was happening under the hood.
I didn't really want to start a controversy -- I just wanted to
understand what was happening.

My understanding of NFS is fairly pedestrian in that I merely get the
big picture. Which is why I posted here.

Thanks,

Wim

-----Original Message-----
From: Chuck Lever [mailto:chuck.lever@oracle.com] 
Sent: Monday, August 06, 2007 12:16 PM
To: Wim Colgate
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS_UNSTABLE vs. FILE and DATA sync.

Wim Colgate wrote:
> Specifically I am trying to inject errors by manually (but politely)
> bringing the NFS server down then up, then down (rinse and repeat ...)
> while doing IO from a linux client. As mentioned the open file is
> O_DIRECT and O_SYNC -- which I thought should mean either the data
hits
> the server's storage or I should get an error; and I'm more than happy
> to deal with an IO error.
> 
> I'm confident the writes are less than wsize (4096 bytes to be
precise).
> 
> 
> Is there a 100% guaranteed method to get the behavior I thought
O_DIRECT
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
>> Servers can return NFS_UNSTABLE to any WRITE request, so I can't
think
> 
>> of a way this might be disabled. 
> 
> Actually, it would be a protocol error for a server to return
> a commitment level less than was requested by the client.  The
> server can return a greater commitment level, but not less than.
> 
>        ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
