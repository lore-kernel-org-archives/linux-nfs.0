From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Desynchronized ncommit
Date: Fri, 20 Apr 2007 10:52:40 -0400
Message-ID: <4628D3B8.6050909@oracle.com>
References: <4627B39A.9070604@oracle.com>
	<1177007342.6623.11.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080904080908020208050300"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeuU4-0000Dg-4v
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 07:53:15 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeuU6-0003IK-8L
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 07:53:14 -0700
In-Reply-To: <1177007342.6623.11.camel@heimdal.trondhjem.org>
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
--------------080904080908020208050300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-04-19 at 14:23 -0400, Chuck Lever wrote:
>> I've noticed this message in my system log over the past few days:
>>
>> Apr 17 10:14:04 schiele kernel: NFS: desynchronized value of nfs_i.ncommit.
>>
>> It looks like it started appearing when the following patch was applied 
>> to 2.6.21-rc.  Any suggestions on what I can do to debug this further?
> 
> Please apply patches 1 - 5 from
> http://client.linux-nfs.org/Linux-2.6.x/2.6.21-rc7/
> and check that they work for you too.

The "Desynchronized ncommit" messages no longer appear, and applications 
overall seem more stable ("Add/remove software packages" wouldn't start 
at all, before, and Thunderbird seems a lot happier).

--------------080904080908020208050300
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------080904080908020208050300
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------080904080908020208050300
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080904080908020208050300--
