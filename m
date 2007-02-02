From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: novice question about large write requests
Date: Fri, 02 Feb 2007 11:10:59 -0500
Message-ID: <45C36293.2080201@oracle.com>
References: <4cf2912c0702020535i2b11691as8bc5ead997fa0d85@mail.gmail.com>
	<45C346B3.4080109@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000808030308030907070705"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HD12C-0001BG-8b
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 08:14:49 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HD127-0008U6-EJ
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 08:13:09 -0800
In-Reply-To: <45C346B3.4080109@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------000808030308030907070705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Venkatesh KS wrote:
>> Folks,
>>
>> I am trying to understand how nfs client handles a server reboot while 
>> issuing multiple
>> unstable writes followed by a commit.
>>
>> Say a user requests a large write requests.
>> nfs client breaks it into multiple 32k requests, each 32k write 
>> request being unstable
>> and finally a commit call before the nfs client returns back to the user.
>>
>> If the server reboots in between these write calls, will the nfs 
>> client know abt it.
>> The write before this may not have made it to disk. If the nfs client 
>> doenst know
>> abt it then it goes ahead with commit call and returns.
> 
> I would suggest checking out RFC1813 for information on this topic.

There is also some explanation of this in the Linux NFS FAQ:

   http://nfs.sourceforge.net/

and we've found Brent Callaghan's "NFS Illustrated" to have some useful 
explanation of reboot recovery with unstable writes.

--------------000808030308030907070705
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principle Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------000808030308030907070705
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------000808030308030907070705
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000808030308030907070705--
