From: Usha Ketineni <uketinen@us.ibm.com>
Subject: Re: [NFS][PATCH] Fix to start nfs services through rsh
Date: Mon, 24 Oct 2005 19:19:16 -0700
Message-ID: <OF05FBEFA5.AE16E351-ON872570A5.000BBE8D-882570A5.000CC0EF@us.ibm.com>
References: <435D6B8C.983D0FA0@sgi.com>
Reply-To: uketinen@us.ibm.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 000CC0EC882570A5_="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUEPR-0007T1-KZ
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 19:19:29 -0700
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUEPN-0003x8-89
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 19:19:29 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9P2JIC1007787
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 22:19:18 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9P2KGNM549484
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 20:20:16 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9P2JI5Y005479
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 20:19:18 -0600
In-Reply-To: <435D6B8C.983D0FA0@sgi.com>
To: James Yarbrough <jmy@sgi.com>
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

This is a multipart message in MIME format.
--=_alternative 000CC0EC882570A5_=
Content-Type: text/plain; charset="US-ASCII"

nfs-admin@lists.sourceforge.net wrote on 10/24/2005 04:17:32 PM:

> I think you might be able to accomplish the same thing by doing the
> following:
> 
>    rsh hostname "/sbin/service nfs start < /dev/null"
> 
> I haven't tried this to do what you want, but I've used this trick
> for other things that want to use getsockname on file descriptor 0.
> 

Yes, that works but not obvious to the users. Also fixing the nfs init 
script 
while starting the rpc.mountd to "daemon rpc.mountd </dev/null" would 
work.
But I felt the code in rpc_init is making a wrong assumption there and 
hence
should be fixed.

Thanks
Usha
 
--=_alternative 000CC0EC882570A5_=
Content-Type: text/html; charset="US-ASCII"


<br>
<br><font size=2><tt>nfs-admin@lists.sourceforge.net wrote on 10/24/2005
04:17:32 PM:<br>
<br>
&gt; I think you might be able to accomplish the same thing by doing the<br>
&gt; following:<br>
&gt; <br>
&gt; &nbsp; &nbsp;rsh hostname &quot;/sbin/service nfs start &lt; /dev/null&quot;<br>
&gt; <br>
&gt; I haven't tried this to do what you want, but I've used this trick<br>
&gt; for other things that want to use getsockname on file descriptor 0.<br>
&gt; <br>
</tt></font>
<br><font size=2><tt>Yes, that works but not obvious to the users. Also
fixing the nfs init script </tt></font>
<br><font size=2><tt>while starting the rpc.mountd to &quot;daemon rpc.mountd
&lt;/dev/null&quot; would work.</tt></font>
<br><font size=2><tt>But I felt the code in rpc_init is making a wrong
assumption there and hence</tt></font>
<br><font size=2><tt>should be fixed.</tt></font>
<br>
<br><font size=2><tt>Thanks</tt></font>
<br><font size=2><tt>Usha</tt></font>
<br><font size=2><tt>&nbsp;</tt></font>
--=_alternative 000CC0EC882570A5_=--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
