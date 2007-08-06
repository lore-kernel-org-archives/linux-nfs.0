From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 06 Aug 2007 13:33:02 -0400
Message-ID: <46B75B4E.8060000@redhat.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEAB@exchrdm.ad.xensource.com>
	<46B74E5C.4060400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II6S1-0003NK-Os
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 10:33:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II6S5-00063e-Jc
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 10:33:09 -0700
In-Reply-To: <46B74E5C.4060400@oracle.com>
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

Chuck Lever wrote:
> Wim Colgate wrote:
>> If I have a soft mount, and open a file with O_DIRECT and O_SYNC, 
>> should I ever expect a callback (nfs_writeback_done) with a 
>> successful task->tk_status (i.e >= 0) with the committed state 
>> (resp->verf->committed) set to NFS_UNSTABLE?
>
> Yes, this can happen if the server decides to return NFS_UNSTABLE. 
> Rare, but possible.
>
>> A secondary question: if the above is expected, does this occur 
>> because someone is caching the write and is there a mechanism to 
>> disable this effect?
>
> Servers can return NFS_UNSTABLE to any WRITE request, so I can't think 
> of a way this might be disabled. 

Actually, it would be a protocol error for a server to return
a commitment level less than was requested by the client.  The
server can return a greater commitment level, but not less than.

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
