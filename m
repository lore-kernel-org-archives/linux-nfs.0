From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 12:24:45 -0400
Message-ID: <46D6EF4D.30700@oracle.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<20070830101249.GA9880@janus> <46D6AFBC.3000208@redhat.com>
	<46D6E9CF.4000901@oracle.com> <46D6EB44.7050600@redhat.com>
	<20070830161903.GH26863@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070905070500020105020107"
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQmr5-0005B7-OA
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:26:52 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQmr7-0001cq-VH
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:26:56 -0700
In-Reply-To: <20070830161903.GH26863@fieldses.org>
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
--------------070905070500020105020107
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Thu, Aug 30, 2007 at 12:07:32PM -0400, Peter Staubach wrote:
>> Chuck Lever wrote:
>>> From my experience, generally mountd (on most any server 
>>> implementation) has been a scalability problem in these scenarios.  It 
>>> can't handle more than a few requests per second.
>> Perhaps we need to look at multithreading mountd?  Ala Solaris?
> 
> Does nfs-utils commit 11d34d1 (below) do the job?

This solves part of the problem.  If mountd depends on external services 
like DNS and netgroup lookups, multithreading will help only somewhat.

--------------070905070500020105020107
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


--------------070905070500020105020107
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------070905070500020105020107
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070905070500020105020107--
