From: "Eli Stair" <estair@ilm.com>
Subject: Re: Latency problem with some clients but not others
Date: Wed, 15 Aug 2007 10:58:03 -0700
Message-ID: <6E56E676C9D6A74EBC980144BC06A17D04BB45E4@mailbox03.lucas.alllucas.com>
References: <46C33597.3030004@caps-entreprise.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1864692396=="
To: "Romain Dolbeau" <romain.dolbeau@caps-entreprise.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILN8B-0004eo-7m
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 10:58:07 -0700
Received: from gateway02.lucasfilm.com ([63.82.98.222])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILN8D-0006lK-3W
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 10:58:11 -0700
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

This is a multi-part message in MIME format.

--===============1864692396==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C7DF65.D32765C6"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C7DF65.D32765C6
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


You can set some significant performance variables affecting your =
ethernet devices with ethtool.  I personally turn off TSO (tcp =
segmentation offload) as have seen this cause issues in production on =
e1000 chipsets from a number of different vendors, with a variety of =
drivers.  I haven't seen a lot of data on the new NAPI-mode e1000 =
driver, but it could have the possibility to introduce latency issues =
with "enhanced" interrupt coalescing and buffering.  I'm not sure how =
you tune the internals on THAT driver, but on every other NIC you do so =
with the 'ethtool -C eth{n}' commands. =20

YMMV on those particular fronts, but I've had good luck fixing intel =
gigabit issues disabling offload functions, and improving bandwidth =
performance on a number of broadcom chipsets with ethtool coalesce =
settings.  I'd suggest you get some hard numbers for comparison before =
making any changes, using netperf or iperf.  That way you can quantify =
it at least.

If I entirely misunderstood your post, and you're having problems with =
the 8169 systems, not the intel Xeon with e1000, you might want to =
seriously consider ditching the Realtek (8169) and test with another =
card in that problematic system.  Easiest and most direct way to test.


/eli

-----Original Message-----
From: nfs-bounces@lists.sourceforge.net on behalf of Romain Dolbeau
Sent: Wed 8/15/2007 10:19 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] Latency problem with some clients but not others
=20
Hello all,

I have a strange latency problem that affect some clients
but not others. The server is a x86_64 Debian machine.

I've created a test case with just 2 64 bits clients. Both use
the same kernel, and have the same packages installed. They both
mount the same filesystems at the mountpoint through amd (the
maps are distributed through NIS).

The user is the same, with one single logging through SSH.
Nothing is running (except kdm) on either clients.
All machines are directly hooked to the same gigabit switch.
The network traffic was extremely low during the test.
Both clients were freshly rebooted.

One of the client is a dual Xeon 5130 system, with an on-board
intel NIC (module e1000). The other is a single Core 2 Duo 6320,
with an on-board ??? NIC (module r8169).

When doing a ./configure (lots of small r/w accesses) inside one
of the NFS mounted filesystem, the first system is fairly fast,
while the other is much slower - each line of the configure script
takes up to a second to display a result. *But*, pure throughput is
fine - if I use dd to write or read a large file, the speed is what
I would expect from the wire.

The problem is reproductible to all similar clients to the
second system, but I also have other clients (for instance
old 32 bits systems with 3c59x cards) that do not exhibit
the problem. In fact, it seems that all my 32 bits clients
are fast (well, as fast as they can be :-), and all my 64 bits
are slow, except two : the one above, and an old Pentium D
machine with an e100 card.

Any idea where I should look ? My only clue is that all my slow
64 bits client uses the same driver (r8169), whereas the fast one
uses e1000 and e100, could that be the source of the problem ?
(I don't havea spare NIC to try) ; is there any know problem
with such cheap on-board NIC ? How could I tell ?

Thanks in advance for any help.

P.S. just in case it's significant...

* mount display : "type nfs=20
(nodev,nosuid,nounmount,noatime,rsize=3D8192,wsize=3D8192,vers=3D3,proto=3D=
tcp)"
  for all filesystems on all clients.
* kernel is current Debian stable (2.6.18-4) or testing (2.6.21-2),
  same symptoms for both.
* I've tried both the included r8169 driver and the one from Realtek,
  same symptoms for both.

--=20
Romain Dolbeau
<romain.dolbeau@caps-entreprise.com>


-------------------------------------------------------------------------=

This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



------_=_NextPart_001_01C7DF65.D32765C6
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7652.24">
<TITLE>RE: [NFS] Latency problem with some clients but not =
others</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>

<P><FONT SIZE=3D2>You can set some significant performance variables =
affecting your ethernet devices with ethtool.&nbsp; I personally turn =
off TSO (tcp segmentation offload) as have seen this cause issues in =
production on e1000 chipsets from a number of different vendors, with a =
variety of drivers.&nbsp; I haven't seen a lot of data on the new =
NAPI-mode e1000 driver, but it could have the possibility to introduce =
latency issues with &quot;enhanced&quot; interrupt coalescing and =
buffering.&nbsp; I'm not sure how you tune the internals on THAT driver, =
but on every other NIC you do so with the 'ethtool -C eth{n}' =
commands.&nbsp;<BR>
<BR>
YMMV on those particular fronts, but I've had good luck fixing intel =
gigabit issues disabling offload functions, and improving bandwidth =
performance on a number of broadcom chipsets with ethtool coalesce =
settings.&nbsp; I'd suggest you get some hard numbers for comparison =
before making any changes, using netperf or iperf.&nbsp; That way you =
can quantify it at least.<BR>
<BR>
If I entirely misunderstood your post, and you're having problems with =
the 8169 systems, not the intel Xeon with e1000, you might want to =
seriously consider ditching the Realtek (8169) and test with another =
card in that problematic system.&nbsp; Easiest and most direct way to =
test.<BR>
<BR>
<BR>
/eli<BR>
<BR>
-----Original Message-----<BR>
From: nfs-bounces@lists.sourceforge.net on behalf of Romain Dolbeau<BR>
Sent: Wed 8/15/2007 10:19 AM<BR>
To: nfs@lists.sourceforge.net<BR>
Subject: [NFS] Latency problem with some clients but not others<BR>
<BR>
Hello all,<BR>
<BR>
I have a strange latency problem that affect some clients<BR>
but not others. The server is a x86_64 Debian machine.<BR>
<BR>
I've created a test case with just 2 64 bits clients. Both use<BR>
the same kernel, and have the same packages installed. They both<BR>
mount the same filesystems at the mountpoint through amd (the<BR>
maps are distributed through NIS).<BR>
<BR>
The user is the same, with one single logging through SSH.<BR>
Nothing is running (except kdm) on either clients.<BR>
All machines are directly hooked to the same gigabit switch.<BR>
The network traffic was extremely low during the test.<BR>
Both clients were freshly rebooted.<BR>
<BR>
One of the client is a dual Xeon 5130 system, with an on-board<BR>
intel NIC (module e1000). The other is a single Core 2 Duo 6320,<BR>
with an on-board ??? NIC (module r8169).<BR>
<BR>
When doing a ./configure (lots of small r/w accesses) inside one<BR>
of the NFS mounted filesystem, the first system is fairly fast,<BR>
while the other is much slower - each line of the configure script<BR>
takes up to a second to display a result. *But*, pure throughput is<BR>
fine - if I use dd to write or read a large file, the speed is what<BR>
I would expect from the wire.<BR>
<BR>
The problem is reproductible to all similar clients to the<BR>
second system, but I also have other clients (for instance<BR>
old 32 bits systems with 3c59x cards) that do not exhibit<BR>
the problem. In fact, it seems that all my 32 bits clients<BR>
are fast (well, as fast as they can be :-), and all my 64 bits<BR>
are slow, except two : the one above, and an old Pentium D<BR>
machine with an e100 card.<BR>
<BR>
Any idea where I should look ? My only clue is that all my slow<BR>
64 bits client uses the same driver (r8169), whereas the fast one<BR>
uses e1000 and e100, could that be the source of the problem ?<BR>
(I don't havea spare NIC to try) ; is there any know problem<BR>
with such cheap on-board NIC ? How could I tell ?<BR>
<BR>
Thanks in advance for any help.<BR>
<BR>
P.S. just in case it's significant...<BR>
<BR>
* mount display : &quot;type nfs<BR>
(nodev,nosuid,nounmount,noatime,rsize=3D8192,wsize=3D8192,vers=3D3,proto=3D=
tcp)&quot;<BR>
&nbsp; for all filesystems on all clients.<BR>
* kernel is current Debian stable (2.6.18-4) or testing (2.6.21-2),<BR>
&nbsp; same symptoms for both.<BR>
* I've tried both the included r8169 driver and the one from =
Realtek,<BR>
&nbsp; same symptoms for both.<BR>
<BR>
--<BR>
Romain Dolbeau<BR>
&lt;romain.dolbeau@caps-entreprise.com&gt;<BR>
<BR>
<BR>
-------------------------------------------------------------------------=
<BR>
This SF.net email is sponsored by: Splunk Inc.<BR>
Still grepping through log files to find problems?&nbsp; Stop.<BR>
Now Search log events and configuration files using AJAX and a =
browser.<BR>
Download your FREE copy of Splunk now &gt;&gt;&nbsp; <A =
HREF=3D"http://get.splunk.com/">http://get.splunk.com/</A><BR>
_______________________________________________<BR>
NFS maillist&nbsp; -&nbsp; NFS@lists.sourceforge.net<BR>
<A =
HREF=3D"https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.s=
ourceforge.net/lists/listinfo/nfs</A><BR>
<BR>
<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C7DF65.D32765C6--


--===============1864692396==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1864692396==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1864692396==--
