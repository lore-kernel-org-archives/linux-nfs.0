From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: startup instructions on CITI's NFSv4 website, etc.
Date: Thu, 12 Feb 2004 16:34:52 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFA29AEF0E.73E73603-ON88256E37.00664627-88256E39.0003317D@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4A4DFF5C0B78f9e8a93df938690918c07BBE4A4DFF5C0B7"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArRJr-0002UH-L6
	for nfs@lists.sourceforge.net; Thu, 12 Feb 2004 16:36:35 -0800
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1ArRIO-0004OR-Rm
	for nfs@lists.sourceforge.net; Thu, 12 Feb 2004 16:35:04 -0800
To: nfsv4-wg@citi.umich.edu
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

--0__=07BBE4A4DFF5C0B78f9e8a93df938690918c07BBE4A4DFF5C0B7
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






Re: http://www.citi.umich.edu/projects/nfsv4/linux

I believe the proper directory to use for rpc_pipefs should be
/var/lib/nfs/rpc_pipefs (as in the sample idmapd.conf file), not
/var/lib/rpc_pipes as documented.  This should be corrected where it
describes the entry in /etc/fstab as well as the mkdir command.  Or, is=
 the
documented directory fine to use as long as the sample idmapd.conf file=
 is
updated to match?  Either way, one of these needs to change, or at the =
very
least make a note on the website stating these need to match.

Also, the instructions for starting the daemons on both the server and
client are not quite correct- mountd, idmapd and nfsd should each be
prepended by "rpc.", for example, rpc.idmapd.

btw, I also discovered that on 2.6.1 with the latest patches from the
website (i.e. CITI_NFS4_ALL-3) with every kernel parameter mentioned on=
 the
website compiled directly into the kernel my machine won't boot (last
message displayed is "NET: Registered protocol family 17"), but with
CONFIG_RPCSEC_GSS_KRB5=3Dm the machine boots fine.

Still having a problem getting rpc.gssd started on the client ("GSSD:
Decrypt integrity check failed while getting initial ticket" followed b=
y
"couldn't get krb5 machine ticket"), but that's probably a krb5
configuration problem on my part.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187=

--0__=07BBE4A4DFF5C0B78f9e8a93df938690918c07BBE4A4DFF5C0B7
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Re: <a href=3D"http://www.citi.umich.edu/projects/nfsv4/linux">http:=
//www.citi.umich.edu/projects/nfsv4/linux</a><br>
<br>
I believe the proper directory to use for rpc_pipefs should be /var/lib=
/nfs/rpc_pipefs (as in the sample idmapd.conf file), not /var/lib/rpc_p=
ipes as documented.  This should be corrected where it describes the en=
try in /etc/fstab as well as the mkdir command.  Or, is the documented =
directory fine to use as long as the sample idmapd.conf file is updated=
 to match?  Either way, one of these needs to change, or at the very le=
ast make a note on the website stating these need to match.<br>
<br>
Also, the instructions for starting the daemons on both the server and =
client are not quite correct- mountd, idmapd and nfsd should each be pr=
epended by &quot;rpc.&quot;, for example, rpc.idmapd.<br>
<br>
btw, I also discovered that on 2.6.1 with the latest patches from the w=
ebsite (i.e. CITI_NFS4_ALL-3) with every kernel parameter mentioned on =
the website compiled directly into the kernel my machine won't boot (la=
st message displayed is &quot;NET: Registered protocol family 17&quot;)=
, but with CONFIG_RPCSEC_GSS_KRB5=3Dm the machine boots fine.<br>
<br>
Still having a problem getting rpc.gssd started on the client (&quot;GS=
SD: Decrypt integrity check failed while getting initial ticket&quot; f=
ollowed by &quot;couldn't get krb5 machine ticket&quot;), but that's pr=
obably a krb5 configuration problem on my part.<br>
<br>
Regards,<br>
---<br>
Bruce Allan  &lt;bruce.allan@us.ibm.com&gt;<br>
Software Engineer, Linux Technology Center<br>
IBM Corporation, Beaverton OR<br>
503-578-4187   IBM Tie-line 775-4187<br>
</body></html>=

--0__=07BBE4A4DFF5C0B78f9e8a93df938690918c07BBE4A4DFF5C0B7--



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
