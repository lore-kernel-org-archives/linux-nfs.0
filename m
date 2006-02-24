From: "Abhishek" <abhimal@hcl.in>
Subject: Re: query required
Date: Fri, 24 Feb 2006 09:45:46 +0530
Message-ID: <001d01c638f8$fc741a30$027d0297@hcl01>
References: <001a01c6387a$1e166eb0$027d0297@hcl01> <200602231443.26532.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCUN3-00029z-0S
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 20:15:57 -0800
Received: from www.hclinsys.com ([203.90.70.241])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCUN0-00060s-1U
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 20:15:56 -0800
To: "Vincent Roqueta" <vincent.roqueta@ext.bull.net>,
	<nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

 Thanks for the update, regarding my second query, I still have a query

 If I want this restriction of nfs version to be done from server, than w=
hat=20
should I do.

Meaning,  I want the server to permit only nfs version 2 or 3 irrespectiv=
e=20
of which version
client wanna want to mount a exported file syste.



Rgds,

Abhishek


----- Original Message -----=20
From: "Vincent Roqueta" <vincent.roqueta@ext.bull.net>
To: <nfs@lists.sourceforge.net>
Cc: "Abhishek" <abhimal@hcl.in>
Sent: Thursday, February 23, 2006 19:13 PM
Subject: Re: [NFS] query required


>
> Le Jeudi 23 F=E9vrier 2006 14:07, Abhishek a =E9crit :
>> HI,
>>      I have questions regarding NFS,
>>
>> 1.)  How to find which version of NFS am I using.
> type mount  -v on the client.
> If version is not
>
>> 2.) How to switch from one version to other version.
> mount -t nfs -o nfsvers=3D2/3  server:/exported/directory /mount/point/
>
>
> for nfs4
> mount -t nfs4 server:/ /mount/point/
>
>
> Vincent
>
> DISCLAIMER:
> -----------------------------------------------------------------------=
---------------------------------------
>
> This e-mail contains confidential and/or privileged information. If you=
=20
> are not the intended recipient
> (or have received this e-mail in error)please notify the sender=20
> immediately and destroy this e-mail.
> Any unauthorized copying, disclosure, use or distribution of the materi=
al=20
> in this e-mail is strictly forbidden.
> -----------------------------------------------------------------------=
----------------------------------------


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
