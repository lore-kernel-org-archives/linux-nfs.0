From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 12:01:19 -0400
Message-ID: <46D6E9CF.4000901@oracle.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<20070830101249.GA9880@janus> <46D6AFBC.3000208@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050804050604050700060105"
Cc: nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQmTJ-0002eS-Nh
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:02:18 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQmTM-0007Eu-Rh
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:02:22 -0700
In-Reply-To: <46D6AFBC.3000208@redhat.com>
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
--------------050804050604050700060105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Frank van Maarseveen wrote:
>> On Thu, Aug 23, 2007 at 04:12:30PM -0400, Peter Staubach wrote:
>>  
>>> I would guess that not so many people are using the "bg" option,
>>> period.  Many of Linux's customers are ex-Sun customers and they
>>> were educated to use autofs and to move away from and stay away
>>> from static mounts via fstab or vfstab.
>>>
>>> The "bg" option was a hack added to speed up system booting.
>>>     
>>
>> No, it is indispensable to recover properly from a power outage:
>> servers tend to boot slower than clients. Also, it is not unusual to
>> have some minor network/server problems after an outage causing the
>> mount to fail.
>>
>> Without the bg option a temporary power outage may render all client
>> systems unusable.
> 
> And a better solution to this problem is still to use autofs.
> 
> That said, what use are the clients _until_ the servers are up?
> The applications on them can't run correctly because the file
> systems that they depend upon may or may not be there yet.  With
> autofs, you would have a chance of getting the synchronization
> right.
> 
> You also get all sorts of benefits such as decreased resource
> usage (by not having inactive file systems mounted), reduced
> hangs (by not having inactive file systems from servers which
> go down still mounted), in addition to the situation described
> above and other benefits as well.
> 
> I do recognize that we can't get rid of the bg option, but I
> would request that people using it consider different alternatives
> to solving their problems.

For the record, one downside to using automounter is the mount storm 
that is caused when a distributed application starts up on multiple 
clients requiring many NFS mount points on each client.  This is one 
reason some sites choose not to use automounter.  "bg"s retry behavior, 
though a kludge, is somewhat more friendly.

 From my experience, generally mountd (on most any server 
implementation) has been a scalability problem in these scenarios.  It 
can't handle more than a few requests per second.

--------------050804050604050700060105
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


--------------050804050604050700060105
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------050804050604050700060105
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050804050604050700060105--
