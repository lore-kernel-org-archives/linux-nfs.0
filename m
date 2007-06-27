From: "Adam Thomas" <nfs@adamthomas.us>
Subject: Exporting Nested Directories
Date: Wed, 27 Jun 2007 14:41:49 -0400
Message-ID: <19d180740706271141i7592b8bcu9b0c646ab62f550f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1559034520=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3cSa-0004lz-GT
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 11:41:48 -0700
Received: from wr-out-0506.google.com ([64.233.184.238])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3cSc-0000rG-Mx
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 11:41:52 -0700
Received: by wr-out-0506.google.com with SMTP id 76so234042wra
	for <nfs@lists.sourceforge.net>; Wed, 27 Jun 2007 11:41:49 -0700 (PDT)
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

--===============1559034520==
Content-Type: multipart/alternative;
	boundary="----=_Part_52130_26813249.1182969709128"

------=_Part_52130_26813249.1182969709128
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I'm trying to export two directories on the same filesystem. The exports
file looks something like this:

/raid 192.168.1.0/23(rw,sync)
/raid/userdir 192.168.1.0/23(rw,sync)

When I try to do this I get a lot of unusual behavior (some clients will
mount, but others won't even though they are within the same IP range).

Are there any restriction with exporting a nested directory like this?

The host is running RHELv3, kernel 2.4.21 with the stock nfs package. The
clients are all recent version of CentOS or Redhat Linux with the most
recent nfs-utils packages.

Thanks,
-Adam

------=_Part_52130_26813249.1182969709128
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

&nbsp;<br>
I&#39;m trying to export two directories on the same filesystem. The exports file looks something like this:&nbsp;<br>
&nbsp;<br>
/raid <a href="http://192.168.1.0/23(rw,sync)">192.168.1.0/23(rw,sync)</a>&nbsp;<br>
/raid/userdir <a href="http://192.168.1.0/23(rw,sync)">192.168.1.0/23(rw,sync)</a>&nbsp;<br>
&nbsp;<br>
When I try to do this I get a lot of unusual behavior (some clients
will mount, but others won&#39;t even though they are within the same IP
range).&nbsp;<br>
&nbsp;<br>
Are there any restriction with exporting a nested directory like this?&nbsp;<br>
&nbsp;<br>
The host is running RHELv3, kernel 2.4.21 with the stock nfs package. The clients are all recent version of CentOS or Redhat Linux with the most recent nfs-utils packages.&nbsp;<br>
&nbsp;<br>
Thanks,&nbsp;<br>
-Adam&nbsp;<br>&nbsp;
<br>

------=_Part_52130_26813249.1182969709128--


--===============1559034520==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1559034520==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1559034520==--
