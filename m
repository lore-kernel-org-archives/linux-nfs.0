From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: Update description of clientaddr= in
 nfs(5)
Date: Fri, 31 Aug 2007 09:56:36 -0400
Message-ID: <46D81E14.3000504@oracle.com>
References: <20070830194810.4524.58037.stgit@monet.1015granger.net>
	<EXNANE01q6DqaJY4kJS00000210@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090600050700000006080400"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR712-0005XG-Kk
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 06:58:28 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR716-0007rE-GH
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 06:58:33 -0700
In-Reply-To: <EXNANE01q6DqaJY4kJS00000210@exnane01.hq.netapp.com>
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
--------------090600050700000006080400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 03:48 PM 8/30/2007, Chuck Lever wrote:
>> +However, in the presence of multiple client network interfaces,
>> +special routing policies, or atypical network topologies, the
>> +exact address to use for callbacks may be difficult for the
>> +mount command to determine automatically.
> 
> "Difficult" doesn't actually say what happens. Perhaps:
> 
> ... atypical network topologies, the ...
> "server may not be able to establish a connection to the
> address supplied by the client to use for callbacks. This in turn
> may lead to degraded client NFSv4 operation."

I think detailing the consequences a little is a good idea, so I'll try 
to work this in.

--------------090600050700000006080400
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


--------------090600050700000006080400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090600050700000006080400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090600050700000006080400--
