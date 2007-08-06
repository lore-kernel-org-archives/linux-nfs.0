From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 06 Aug 2007 15:35:04 -0400
Message-ID: <46B777E8.8080401@oracle.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEAB@exchrdm.ad.xensource.com>	
	<46B74E5C.4060400@oracle.com> <46B755FE.1010909@oracle.com>	
	<1186426710.6616.57.camel@localhost> <46B772CB.1080906@oracle.com>
	<1186427982.6616.67.camel@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060108080706050904070707"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II9Co-0004nA-LB
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 13:29:34 -0700
Received: from agminet02.oracle.com ([141.146.126.229])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II9Cr-0005xq-8x
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 13:29:38 -0700
Received: from agminet01.oracle.com (agminet01.oracle.com [141.146.126.228])
	by agminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l76KT1ga019324
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 6 Aug 2007 15:29:01 -0500
In-Reply-To: <1186427982.6616.67.camel@localhost>
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
--------------060108080706050904070707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
>>> I see no reason why we should care about supporting such a server.
>> I said nothing about whether the server should or should not return such 
>> a value.  I just said that it is a possibility, and that I have observed 
>> the behavior in the field.
>>
>> The client, if it is a good implementation, needs to check for this 
>> possibility and throw an error in that case.
> 
> We have never supported servers that blatantly violate the protocol, and
> I see no reason to be burdening the client with a whole load of checks
> for server protocol violations either.

Take a look at nfs_writeback_done().  You'll see a specific check for a 
"known bug in Tru64 < 5.0" that is exactly the check to see if the 
server is violating this part of the protocol.  Tru64 is not the only 
server where this can happen.

And in fact, the behavior *is* actually "supported" by the client -- I 
believe Linux will attempt to post a COMMIT if the server returns 
NFS_UNSTABLE to *any* write the client has done.

> If you want a tool for testing servers, then use something like pynfs.

No argument there.  Wim, you can precisely determine the request stream 
a server sees with a test client such as pynfs.  However, it appeared 
that you were looking at whole system client-server interaction during 
server instability.

--------------060108080706050904070707
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


--------------060108080706050904070707
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060108080706050904070707
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060108080706050904070707--
