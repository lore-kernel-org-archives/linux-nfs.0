From: Muhammad Irfan Nazir <arfan.se@gmail.com>
Subject: NFS behavior as seen by EXT2
Date: Mon, 19 Dec 2005 16:52:30 +0500
Message-ID: <28437eef0512190352l34a0ba47g96be56cb455608cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_29681_11589376.1134993150636"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EoJZB-0003zN-EA
	for nfs@lists.sourceforge.net; Mon, 19 Dec 2005 03:52:33 -0800
Received: from zproxy.gmail.com ([64.233.162.203])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EoJZA-0007N8-5p
	for nfs@lists.sourceforge.net; Mon, 19 Dec 2005 03:52:33 -0800
Received: by zproxy.gmail.com with SMTP id z3so1083218nzf
        for <nfs@lists.sourceforge.net>; Mon, 19 Dec 2005 03:52:31 -0800 (PST)
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

------=_Part_29681_11589376.1134993150636
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I am involved in research around EXT2 file system. During the ongoing
research project I have noticed nfs behavior for which I would like to
benefit from your experiences.

I am using Red Hat Linux 9.0 (kernel version 2.4.20-8).

*Scenairo:*

The nfs client is required to read a file residing on a remote server.

I monitored nfs requests as recieved by the EXT2 using kernel mode messages=
.
I found the following sequence:

On Client Side:
Application opens file residing on nfs mounted directory.
reads the file
reads the file
reads the file
closes the file

Server side: Requests as recieved by the Ext2

nfs request opens the file
reads the data
closes the file

nfs request opens the file
reads the data
closes the file

nfs request opens the file
reads the data
closes the file

*Behaviour Noticed:*

Nfs client opens the file for every read request and reads the data then
closes the file. And repeats the same procedure for every read request.

*Question:*

It was noted that after each Read, the file is closed,so the Virtual File
System (VFS) file object is deleted.
For next time Read a new VFS level file object is created.

Now nfs keeps record of the last reading position and sends the read reques=
t
to EXT2 with last reading position.


Where as at EXT2 level I was supposing to get the position zero as the file
was closed in the last reading and all its memory references were deleted.

How/where does the nfs keeps the record of the previous reading position?

I want to get the reference to the documentation stating the read/write
behaviour of nfs.

with best regards,

 Arfan
--
Muhammad Arfan Nazir
Research Associate
COMSATS Institute of IT (CIIT),
Islamabad, Pakistan
http://csr.comsats.edu.pk/research/multimedia.shtml

------=_Part_29681_11589376.1134993150636
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div>Hi,</div>
<div>
<p>I am involved in research around EXT2 file system. During the ongoing re=
search project I have noticed nfs behavior for which I would like to benefi=
t from your experiences.</p>
<p>I am using Red Hat Linux 9.0 (kernel version 2.4.20-8).</p>
<p><strong>Scenairo:</strong></p>
<p>The nfs client is required to read a file residing on a remote server. <=
/p>
<p>I monitored nfs requests&nbsp;as recieved by the&nbsp;EXT2 using kernel =
mode messages. I found the following sequence:</p>
<p>On Client Side:&nbsp;<br>Application opens file residing on nfs mounted =
directory.<br>reads the file <br>reads the file <br>reads the file<br>close=
s the file</p>
<p>Server side: Requests as recieved by the Ext2</p>
<p>nfs request opens the file<br>reads the data<br>closes the file</p>
<p>nfs request opens the file<br>reads the data<br>closes the file</p>
<p>nfs request opens the file<br>reads the data<br>closes the file<br>&nbsp=
;<br><strong>Behaviour Noticed:</strong></p>
<p>Nfs client opens the file for every read request and reads the data then=
 closes the file. And repeats the same procedure for every read request.&nb=
sp;<br>&nbsp;<br><strong>Question:</strong></p>
<p>It was noted that after each Read, the file is closed,so the Virtual Fil=
e System (VFS) file object is deleted.&nbsp; <br>For next time Read a new V=
FS level file object is created.&nbsp; <br></p>
<p>Now nfs keeps record of the last reading position and sends the read req=
uest to EXT2 with last reading position.</p>
<p><br>Where as at EXT2 level I was supposing to get the position zero as t=
he file was closed in the last reading and all its memory references were d=
eleted.</p>
<p>How/where does the nfs keeps the record of the previous reading position=
?</p>
<p>I want to get the reference to the documentation stating the read/write =
behaviour of nfs.</p>
<p>with best regards,</p>
<p>&nbsp;Arfan <br>-- <br>Muhammad Arfan Nazir<br>Research Associate<br>COM=
SATS Institute of IT (CIIT), <br>Islamabad, Pakistan <br><a href=3D"http://=
csr.comsats.edu.pk/research/multimedia.shtml">http://csr.comsats.edu.pk/res=
earch/multimedia.shtml
</a> </p></div>

------=_Part_29681_11589376.1134993150636--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
