From: Jim Farley <j_farley1@yahoo.ca>
Subject: stale nfs handles
Date: Wed, 1 Jun 2005 17:53:19 -0400 (EDT)
Message-ID: <20050601215319.78208.qmail@web33613.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-76675851-1117662799=:78201"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddb9W-0001ok-2P
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 14:53:30 -0700
Received: from web33613.mail.mud.yahoo.com ([68.142.199.245])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1Ddb9U-0002SF-9l
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 14:53:29 -0700
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

--0-76675851-1117662799=:78201
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,
=20
We have been running an nfs environment for a couple of years now without=
 difficulties.
Unfortunately when we upgraded the nfs server from RedHat9 to Fedora Core=
 3 (2.6.9-1.667smp), clients (10 RedHat 9 systems, 2.4.20-8smp) started g=
etting stale NFS file handles.
I used tcpdump and verified that the messages are exchanged between the s=
erver and client without delay which would indicate the network is not a =
problem. I have also verified that the server is not under heavy load (cp=
u, memory, network), nor are the clients.
=20
We basically take the defaults on the client and on the server:
=20
Client:
cat /proc/mounts:
192.168.11.10:/home /home nfs rw,v3,rsize=3D4096,wsize=3D4096,hard,intr,u=
dp,lock,addr=3D192.168.11.10 0 0

Server:
cat /etc/exports
/home 192.168.11.0/255.255.255.0(rw,no_subtree_check)
=20
What I have done:
- increase number of nfsd's to 32
- disabled caching on one client (noac)
- reverted the server from the ext3 filesystem to ext2
=20
None of this has helped. Is there anything else I can try?
=20
Thanks,
Jimmy
=20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20
--0-76675851-1117662799=:78201
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<DIV>Hi,</DIV>
<DIV>&nbsp;</DIV>
<DIV>We have been running an nfs environment for a couple of years now wi=
thout difficulties.</DIV>
<DIV>Unfortunately when we upgraded the nfs server from RedHat9 to Fedora=
 Core 3 (2.6.9-1.667smp), clients (10 RedHat 9 systems, 2.4.20-8smp) star=
ted getting stale NFS file handles.</DIV>
<DIV>I used tcpdump and verified that the messages are exchanged between =
the server and client without delay which would indicate the network is n=
ot a problem. I have also verified that the server is not under heavy loa=
d (cpu, memory, network), nor are the clients.</DIV>
<DIV>&nbsp;</DIV>
<DIV>We basically take the defaults on the client and on the&nbsp;server:=
</DIV>
<DIV>&nbsp;</DIV>
<DIV>Client:</DIV>
<DIV>cat /proc/mounts:</DIV>
<DIV>192.168.11.10:/home /home nfs rw,v3,rsize=3D4096,wsize=3D4096,hard,i=
ntr,udp,lock,addr=3D192.168.11.10 0 0<BR></DIV>
<DIV>Server:</DIV>
<DIV>cat /etc/exports<BR>/home 192.168.11.0/255.255.255.0(rw,no_subtree_c=
heck)</DIV>
<DIV>&nbsp;</DIV>
<DIV>What I have done:</DIV>
<DIV>- increase number of nfsd's to 32</DIV>
<DIV>- disabled caching on one client (noac)</DIV>
<DIV>- reverted the server from the ext3 filesystem to ext2</DIV>
<DIV>&nbsp;</DIV>
<DIV>None of this has helped. Is there anything else I can try?</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks,</DIV>
<DIV>Jimmy</DIV>
<DIV>&nbsp;</DIV><p>__________________________________________________<br=
>Do You Yahoo!?<br>Tired of spam?  Yahoo! Mail has the best spam protecti=
on around <br>http://mail.yahoo.com=20
--0-76675851-1117662799=:78201--


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
