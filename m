From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 12:18:54 -0400
Message-ID: <46D6EDEE.5060907@oracle.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<20070830101249.GA9880@janus> <46D6AFBC.3000208@redhat.com>
	<46D6E9CF.4000901@oracle.com> <46D6EB44.7050600@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070901050602070003050504"
Cc: nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQml3-0004Wv-HK
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:20:37 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQml6-0006ge-NE
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:20:42 -0700
In-Reply-To: <46D6EB44.7050600@redhat.com>
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
--------------070901050602070003050504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Chuck Lever wrote:
>> For the record, one downside to using automounter is the mount storm 
>> that is caused when a distributed application starts up on multiple 
>> clients requiring many NFS mount points on each client.  This is one 
>> reason some sites choose not to use automounter.  "bg"s retry 
>> behavior, though a kludge, is somewhat more friendly.
> 
> If the application on each client is going to need many mount
> points, then how does "bg" do anything but increase the number
> of concurrent mount requests coming from each client, thus
> increasing the load?

"bg" has an exponential backoff, so the load increase isn't terribly 
bothersome.  It's the "bg" recovery mechanism that's useful here for 
getting all the mount requests to be successful in a nondeterministic 
environment.

I'm not arguing against automounter here; I'm just presenting a typical 
use case that is common enough for us to pay some heed.

>> From my experience, generally mountd (on most any server 
>> implementation) has been a scalability problem in these scenarios.  It 
>> can't handle more than a few requests per second.
> 
> Perhaps we need to look at multithreading mountd?  Ala Solaris?

Yes, although I was thinking of ways to make the client side more 
friendly, say, by serializing mount requests to the same server, since 
we don't have any influence on the scalability of mountd in non-Linux 
NFS implementations.

--------------070901050602070003050504
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


--------------070901050602070003050504
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------070901050602070003050504
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070901050602070003050504--
