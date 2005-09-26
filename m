From: GOKUL HUGGAHALLI <gokul.adi@gmail.com>
Subject: Problem with NFS
Date: Mon, 26 Sep 2005 14:36:29 -0400
Message-ID: <73f1ae830509261136253f29e4@mail.gmail.com>
Reply-To: GOKUL HUGGAHALLI <gokul.adi@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_1169_1540005.1127759789097"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EJxqB-0000Ro-2s
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 11:36:39 -0700
Received: from xproxy.gmail.com ([66.249.82.199])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EJxq8-0002it-SR
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 11:36:38 -0700
Received: by xproxy.gmail.com with SMTP id s7so1290674wxc
        for <nfs@lists.sourceforge.net>; Mon, 26 Sep 2005 11:36:29 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

------=_Part_1169_1540005.1127759789097
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,
 I have two machines ADB and AWEB
Linux adb 2.4.21-27.0.4.ELsmp #1 SMP Sat Apr 16 18:43:06 EDT 2005 i686 i686
i386 GNU/Linux
Linux aweb 2.4.21-32.ELsmp #1 SMP Fri Apr 15 21:17:59 EDT 2005 i686 i686
i386 GNU/Linux
 ADB runs Oracle and AWEB runs Apache and Coldfusion. I have set up a drive
on machine AWEB which is mountable from machine ADB. I am mounting it so
that I can transfer around 130GB of RMAN backup from ADB to AWEB. I am usin=
g
nfs so that RMAN is can push the backup from ADB to AWEB.
 The problem I am facing right now is that in the middle of that transfer
the AWEB machine becomes unresponsive. I cant even ping it from anywhere
else. After some hours it recovers on its own. The only other option is to
bounce AWEB. I checked the /var/log/messages in AWEB after it recovers to
see if there are any problems but it does not indicate that there is a
problem.
 Are there any bugs which relate to this problem? How do I go about solving
this problem.
 Thank you,
Gokul

------=_Part_1169_1540005.1127759789097
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div>Hello,</div>
<div>&nbsp;</div>
<div>I have two machines&nbsp;ADB and AWEB</div>
<div>Linux&nbsp;adb 2.4.21-27.0.4.ELsmp #1 SMP Sat Apr 16 18:43:06 EDT 2005=
 i686 i686 i386 GNU/Linux</div>
<div>Linux aweb 2.4.21-32.ELsmp #1 SMP Fri Apr 15 21:17:59 EDT 2005 i686 i6=
86 i386 GNU/Linux</div>
<div>&nbsp;</div>
<div>ADB runs Oracle and&nbsp;AWEB runs Apache and Coldfusion. I have set u=
p a drive on machine&nbsp;AWEB which is mountable from machine ADB. I am mo=
unting it so that I can transfer around 130GB of RMAN backup from ADB to AW=
EB. I am using nfs so that RMAN is&nbsp;can push&nbsp;the backup&nbsp;from =
ADB to AWEB.
</div>
<div>&nbsp;</div>
<div>The problem I am facing right now is that in the middle of that transf=
er the AWEB machine becomes unresponsive.&nbsp;I cant even ping it from any=
where else. After some hours it recovers on its own. The only other option =
is to bounce AWEB. I checked the /var/log/messages in AWEB after it recover=
s to see if there are any problems but it does not indicate that there&nbsp=
;is a problem.
</div>
<div>&nbsp;</div>
<div>Are there any bugs which relate to this problem? How do I go about sol=
ving this problem.</div>
<div>&nbsp;</div>
<div>Thank you,</div>
<div>Gokul</div>
<div>&nbsp;</div>

------=_Part_1169_1540005.1127759789097--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
