From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: umount fails with device busy
Date: Thu, 23 Aug 2007 18:01:47 -0400
Message-ID: <46CE03CB.4070300@oracle.com>
References: <20070823184544.237460@gmx.net> <46CDE805.4090909@oracle.com>
	<46CDEE3A.3040809@redhat.com> <46CDEF90.90007@oracle.com>
	<46CDF3BE.9030509@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000500060508000404080501"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOKlx-0003h4-2q
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 15:03:25 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOKlz-0002WE-RK
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 15:03:29 -0700
In-Reply-To: <46CDF3BE.9030509@redhat.com>
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
--------------000500060508000404080501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Peter Staubach wrote:
> Chuck Lever wrote:
>>>>> When I run umount during these ops I get an device busy. Any help 
>>>>> would be very appreciated!
>>>>
>>>> This is normal and expected behavior.  One problem may be that your 
>>>> server is slow, and thus there are RPCs left outstanding for a bit 
>>>> on your client after your application exits.  The COMMIT calls from 
>>>> that trace suggest that there is dirty data the client is writing 
>>>> back to the server. 
>>>
>>> It seems to me that this should not be the expected behavior unless
>>> the file system is mounted "nocto".  Is it?
>>
>> I'm a little puzzled myself about what dirty data there might be left 
>> after the application quits.  However, I'll be there is an mmap() 
>> lurking somewhere in the background...
>>
>> Data that was dirtied via a mapped file is not subject to the 
>> writeback part of close-to-open.
> 
> I don't think that I agree with this last statement.  Although
> it can not be implemented using the normal close system call,
> something should trigger the flush of any dirty pages and wait
> for them to complete.

This is the way Linux implements dirty mmaps on NFS because that's the 
way Linus wants it.  I didn't mean to imply that's the way it *should* 
work, merely the way it *does* work in Linux.

--------------000500060508000404080501
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


--------------000500060508000404080501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------000500060508000404080501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000500060508000404080501--
