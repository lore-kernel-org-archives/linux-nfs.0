From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: StreamCorruptedException Urgent.
Date: Fri, 17 Aug 2007 12:07:43 -0400
Message-ID: <46C5C7CF.5040600@oracle.com>
References: <9AE21525342E4C4F8ECDC61B978843BD03823274@mtw01ex02.mindtree.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060605030103010505080909"
Cc: nfs@lists.sourceforge.net
To: Ignatius Pradeep Kumar Joseph <IgnatiusPradeep_Joseph@mindtree.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM5Pb-0007qV-1o
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 10:15:03 -0700
Received: from rgminet02.oracle.com ([148.87.113.119])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IM5Pd-0004Xp-KV
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 10:15:07 -0700
Received: from rgminet01.oracle.com (rgminet01.oracle.com [148.87.113.118])
	by rgminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l7HGAAoe026998
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 17 Aug 2007 10:10:10 -0600
In-Reply-To: <9AE21525342E4C4F8ECDC61B978843BD03823274@mtw01ex02.mindtree.com>
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
--------------060605030103010505080909
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

Ignatius Pradeep Kumar Joseph wrote:
> We are facing the following issue =93StreamCorruptedException=94, when =
we=20
> are writing large files into *NFS* directory. The report we were trying=
=20
> to run was of 41MB size.
>=20
> When we un-mount the NFS and write the large file directly to the=20
> application server directly, we don=92t face any issues. For the moment=
,=20
> in order to make the CAT successful, we have un-mounted the NFS in QA2=20
> and set up the same in QA3 where the stack is deployed.
>=20
> =20
>=20
> But we have to test these reports with the NFS before we can release it=
=20
> to other environments. Please help us in finding why this issue is only=
=20
> happening when we are using NFS.
>=20
> =20
>=20
> See below part of the stack trace. From our end we are also looking at=20
> various forums to resolve this issue.

Hello-

The Exception message you posted is generated entirely within your Java=20
environment.  Your problem description is very specific to your=20
environment and application.  You need to debug your Java application=20
first to determine what exactly NFS is doing to trigger this issue.

Without a lot of domain expertise, I suggest you start with strace to=20
find out what system calls your application uses, and what return codes=20
they generate, as your application encounters the error.

--------------060605030103010505080909
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


--------------060605030103010505080909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060605030103010505080909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060605030103010505080909--
