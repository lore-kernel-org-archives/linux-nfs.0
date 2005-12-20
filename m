From: Kenny Simpson <theonetruekenny@yahoo.com>
Subject: NFS TCP settings
Date: Tue, 20 Dec 2005 07:38:37 -0800 (PST)
Message-ID: <20051220153837.63707.qmail@web34102.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EojZe-0005UT-Ez
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 07:38:46 -0800
Received: from web34102.mail.mud.yahoo.com ([66.163.178.100])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EojZb-0005dj-5n
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 07:38:46 -0800
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

Hello,
  Why does the Linux NFS client force the rsize ans wsize to be a power o=
f 2, and why is the TCP
window size equal to the rsize or wsize?

  I am seeing some unfortunate behavior in the NFS traffix patterns I bel=
ieve to be associated
with the interaction of TCP window size and rsize/wsize.

  I have a dedicated connection to a NetApp via GbE crossover cable to el=
iminate any switching
effects, and for the client I have a dual P4 machine running 2.6.15-rc5 +=
 nfs_all patch using an
e1000 NIC.  Jumbo frames (8160) are set on both client and server,=20

I max out the TCP window size and xfer size on the NetApp to 64k, and set=
 the client to mount with
rsize=3Dwsize=3D1M.  After the mount, I see /proc/mounts showing the rsiz=
e and wsize to be 64k -
ethereal shows me the NetApp provided this info during the mount (and I f=
ollowed along in the
source).

  With a xfer size =3D=3D TCP window size, the client must always do an e=
xtra round trip to send the
data.  The total payload is xfer size + RPC overhead, right?  I see in et=
hereal that the client
fills the TCP window, waits for an ACK, then sends the final packet.
  My understanding of RPC is that the server must wait for the final byte=
 of the message before it
can process the request.  Therefore, since the window size is just a litt=
le too small, we get an
extra round trip delay penalty.
  Next I tried dropping the xfer size on the NetApp down to 60k (61440), =
but this made the client
drop its block sizes to 32k.  From the source (inode.c) I see the rsize a=
nd wsize are adjusted by
nfs_block_size, which forces a power of 2.
  Is there really a need for this to be a power of 2?

  This change does help the write behavior, as now the TCP window is not =
filled, and the extra
round trip is eliminated.

  For read behavior, I see the Linux client setting the TCP window size t=
o be the same as the
rsize - hitting the xfer size =3D=3D TCP window size behavior described a=
bove (i.e. an extra round
trip penalty due to filling the TCP window).

  Are these easily changable?  Am I just missing something?

-Kenny


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
