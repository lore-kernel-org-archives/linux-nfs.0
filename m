From: "Chris Penney" <penney@msu.edu>
Subject: Exports question
Date: Tue, 2 May 2006 15:15:34 -0400
Message-ID: <111aefd0605021215v286fc07epb4dac9160b5367e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_6158_8389237.1146597334453"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fb0RT-0003id-Lo
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 12:21:51 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fb0RT-0004vi-JP
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 12:21:51 -0700
Received: from uproxy.gmail.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fb0RR-0003i7-WF
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 12:21:51 -0700
Received: by uproxy.gmail.com with SMTP id c2so2204583ugf
        for <nfs@lists.sourceforge.net>; Tue, 02 May 2006 12:21:48 -0700 (PDT)
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

------=_Part_6158_8389237.1146597334453
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

In my network we have a "secure" subnet that we export a file system /x to
with root_squash set.  On a couple of hosts in that subnet we want
no_root_squash.  So in /etc/exports I have:

/x      10.10.10.3(rw,sync,no_subtree_check,no_root_squash)
/x      10.10.10.0/255.255.255.0(rw,sync,no_subtree_check,root_squash)

When 10.10.10.3 mounts /x I get a syslog message:

May  2 13:30:14 specialbox rpc.mountd: /s exported to both
10.10.10.0/255.255.255.0 and specialbox.domain.com in
10.10.10.0/255.255.255.0,specialbox.domain.com

Is there anything wrong with what I'm doing?  I assume this is just a
warning?

   Chris

------=_Part_6158_8389237.1146597334453
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div>&nbsp;</div>
<div>In my network we have a &quot;secure&quot; subnet that we export a fil=
e system /x to with root_squash set.&nbsp;&nbsp;On&nbsp;a couple of hosts i=
n that subnet we want no_root_squash.&nbsp; So in /etc/exports I have:</div=
>
<div>&nbsp;</div>
<div>/x&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 10.10.10.3(rw,sync,no_subtree_check,n=
o_root_squash)<br>/x&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href=3D"http://10.10.=
10.0/255.255.255.0(rw,sync,no_subtree_check,root_squash)">10.10.10.0/255.25=
5.255.0(rw,sync,no_subtree_check,root_squash)</a>
<br>&nbsp;</div>
<div>When <a href=3D"http://10.10.10.3">10.10.10.3</a> mounts /x I get a sy=
slog message:</div>
<div>&nbsp;</div>
<div>May&nbsp; 2 13:30:14&nbsp;specialbox rpc.mountd: /s exported to both <=
a href=3D"http://10.10.10.0/255.255.255.0">10.10.10.0/255.255.255.0</a> and=
&nbsp;<a href=3D"http://specialbox.domain.com">specialbox.domain.com</a> in=
 <a href=3D"http://10.10.10.0/255.255.255.0,specialbox.domain.com">
10.10.10.0/255.255.255.0,specialbox.domain.com</a><br>&nbsp;</div>
<div>Is there anything wrong with what I'm doing?&nbsp; I assume this is ju=
st a warning?</div>
<div>&nbsp;</div>
<div>&nbsp;&nbsp; Chris</div>
<div>&nbsp;</div>

------=_Part_6158_8389237.1146597334453--


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
