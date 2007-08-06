From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 06 Aug 2007 13:10:22 -0400
Message-ID: <46B755FE.1010909@oracle.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEAB@exchrdm.ad.xensource.com>
	<46B74E5C.4060400@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010202090605040201030303"
Cc: nfs@lists.sourceforge.net
To: Wim Colgate <Wim.Colgate@xensource.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II67S-0001DG-Pm
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 10:11:50 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II67V-0002WT-Hp
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 10:11:54 -0700
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

This is a multi-part message in MIME format.
--------------010202090605040201030303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Chuck Lever wrote:
> Wim Colgate wrote:
>> If I have a soft mount, and open a file with O_DIRECT and O_SYNC, 
>> should I ever expect a callback (nfs_writeback_done) with a successful 
>> task->tk_status (i.e >= 0) with the committed state 
>> (resp->verf->committed) set to NFS_UNSTABLE?
> 
> Yes, this can happen if the server decides to return NFS_UNSTABLE. Rare, 
> but possible.

Let me be more clear about this.

O_DIRECT and O_SYNC determine client behavior only.  However, they don't 
necessarily force NFS_FILE_SYNC writes all the time.  For example, if an 
application issues a direct write request that is much larger than the 
current wsize, the Linux NFS client will send the write using 
NFS_UNSTABLE requests followed by a COMMIT.  That makes it easier for 
the server to schedule disk writes more efficiently.

>> A secondary question: if the above is expected, does this occur 
>> because someone is caching the write and is there a mechanism to 
>> disable this effect?
> 
> Servers can return NFS_UNSTABLE to any WRITE request, so I can't think 
> of a way this might be disabled.

Even though an NFS client requests an NFS_FILE_SYNC write, the server 
still has the choice of returning something less, even NFS_UNSTABLE.  In 
general that's a rare occurrence, but is something I've seen in practice.

--------------010202090605040201030303
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


--------------010202090605040201030303
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------010202090605040201030303
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010202090605040201030303--
