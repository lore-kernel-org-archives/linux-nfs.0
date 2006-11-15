From: "Andrei Maslennikov" <andrei.maslennikov@gmail.com>
Subject: Advice needed to debug a failng mount command
Date: Wed, 15 Nov 2006 12:03:53 +0100
Message-ID: <515158c30611150303p5fe79561g894797d71c9c7162@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1716669666=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkIYd-0002BB-Dn
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 03:03:55 -0800
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GkIYc-000110-0l
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 03:03:56 -0800
Received: by nf-out-0910.google.com with SMTP id c31so1069049nfb
	for <nfs@lists.sourceforge.net>; Wed, 15 Nov 2006 03:03:53 -0800 (PST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1716669666==
Content-Type: multipart/alternative;
	boundary="----=_Part_30872_9052853.1163588633226"

------=_Part_30872_9052853.1163588633226
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We have an itanium2 machine installed with "CentOS release 4.4
(Final)", the kernel in use is 2.6.9-42.0.2.EL. This box mounts two
different NFS volumes from two identical servers. The NFS servers
are installed with SUSE LINUX Enterprise Server 9 (x86_64) VERSION =
9 PATCHLEVEL = 3 and the kernel in use is 2.6.5-7.244-smp. Both of
them export NFS volumes using two bounded GigE interfaces (we use
Adaptive Load Balancing of the bonding driver, mode=6).

What happens is that itanium2 client can mount volumes from the nfs1
server but not from the nfs2 server. At the same time there are
other boxes that mount the volumes from both servers without
problems. We have checked out the gigabit links on the client and
server sides and everything seems to work fine.

>From the nfs1 server, we can mount all volumes without problems.

>From the nfs2 server we can not mount anything, the "mount" command
issued on the client hangs forever and the only way to get out of
this is to kill the [rpciod] proccess to bring the box back into a
normal state. Without killing rpciod the box won't reboot. When
the [rpciod] proccess is killed, it produces the following
output:

  nfs2-gig:/vol /vol mount: nfs2-gig:/vol: can't read superblock

On the server side we can see this message in the log:

  Nov 15 11:27:32 nfs2 rpc.mountd: authenticated mount request from
  titanic2-gig.caspur.it:945 for /nfs2/vol (/nfs2/vol)

So it seems to at least recognize the client correctly. Doing
tcpdump on both client and server allows to see that both parties
exchange the messages up to a certain point, and then everything
hangs. Doing tcpdump with a "good" server shows a very similar
pattern of exchanges, but it is hardly possible to locate the
difference in a lot of messages.

We have also tried to reboot the server, to no avail. Clearly
the client is well positioned on the network, as with another
identical server all works fine. So most probably the problem
has to do with the server.

We would greatly appreciate if someone could suggest us what
to look at on the server side.

Thanks ahead!

------=_Part_30872_9052853.1163588633226
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We have an itanium2 machine installed with &quot;CentOS release 4.4<br>
(Final)&quot;, the kernel in use is 2.6.9-42.0.2.EL. This box mounts two<br>
different NFS volumes from two identical servers. The NFS servers<br>
are installed with SUSE LINUX Enterprise Server 9 (x86_64) VERSION =<br>
9 PATCHLEVEL = 3 and the kernel in use is 2.6.5-7.244-smp. Both of<br>
them export NFS volumes using two bounded GigE interfaces (we use<br>
Adaptive Load Balancing of the bonding driver, mode=6).<br>
<br>
What happens is that itanium2 client can mount volumes from the nfs1<br>
server but not from the nfs2 server. At the same time there are<br>
other boxes that mount the volumes from both servers without<br>
problems. We have checked out the gigabit links on the client and<br>
server sides and everything seems to work fine.<br>
<br>
>From the nfs1 server, we can mount all volumes without problems.<br>
<br>
>From the nfs2 server we can not mount anything, the &quot;mount&quot; command <br>
issued on the client hangs forever and the only way to get out of<br>
this is to kill the [rpciod] proccess to bring the box back into a<br>
normal state. Without killing rpciod the box won't reboot. When<br>
the [rpciod] proccess is killed, it produces the following<br>
output:<br>
<br>
&nbsp; nfs2-gig:/vol /vol mount: nfs2-gig:/vol: can't read superblock<br>
<br>
On the server side we can see this message in the log:<br>
<br>
&nbsp; Nov 15 11:27:32 nfs2 rpc.mountd: authenticated mount request from<br>
&nbsp; <a href="http://titanic2-gig.caspur.it:945">titanic2-gig.caspur.it:945</a> for /nfs2/vol (/nfs2/vol)<br>
<br>
So it seems to at least recognize the client correctly. Doing<br>
tcpdump on both client and server allows to see that both parties<br>
exchange the messages up to a certain point, and then everything<br>
hangs. Doing tcpdump with a &quot;good&quot; server shows a very similar<br>
pattern of exchanges, but it is hardly possible to locate the<br>
difference in a lot of messages.<br>
<br>
We have also tried to reboot the server, to no avail. Clearly<br>
the client is well positioned on the network, as with another<br>
identical server all works fine. So most probably the problem<br>
has to do with the server.<br>
<br>
We would greatly appreciate if someone could suggest us what<br>
to look at on the server side.<br>
<br>
Thanks ahead!<br>
<br>

------=_Part_30872_9052853.1163588633226--


--===============1716669666==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1716669666==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1716669666==--
