From: upendra gandhi <upendra.gandhi@oracle.com>
Subject: Re: how to force umount when "Device or resource busy"?
Date: Mon, 01 Nov 2004 08:55:23 -0800
Message-ID: <41866A7B.9030303@oracle.com>
References: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk> <418187A2.6070702@oracle.com> <Pine.LNX.4.58.0411011614310.22404@wombat.indigo.net.au>
Mime-Version: 1.0
Content-Type: text/html; charset=us-ascii
Cc: ms419@freezone.co.uk, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1COfTH-0007fJ-Kt
	for nfs@lists.sourceforge.net; Mon, 01 Nov 2004 08:55:55 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1COfTF-00039F-3T
	for nfs@lists.sourceforge.net; Mon, 01 Nov 2004 08:55:55 -0800
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0411011614310.22404@wombat.indigo.net.au>
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

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
  <title></title>
</head>
<body text="#000000" bgcolor="#ffffff">
Ver:&nbsp;&nbsp;&nbsp; autofs-4.1.3-12<br>
<br>
Ian Kent wrote:<br>
<blockquote type="cite"
 cite="midPine.LNX.4.58.0411011614310.22404@wombat.indigo.net.au">
  <pre wrap="">On Thu, 28 Oct 2004, upendra gandhi wrote:

  </pre>
  <blockquote type="cite">
    <pre wrap="">is there an answer to this we are facing this issue in autofs4
    </pre>
  </blockquote>
  <pre wrap=""><!---->
I Asked for version info. before.

Can you provide it please?

  </pre>
  <blockquote type="cite">
    <pre wrap="">thks

<a class="moz-txt-link-abbreviated" href="mailto:ms419@freezone.co.uk">ms419@freezone.co.uk</a> wrote:

    </pre>
    <blockquote type="cite">
      <pre wrap="">How does one unmount when umount doesn't work?

Somehow, I got an NFS / AutoFS mount that just won't unmount.

I noticed /var/autofs/net was mounted twice, so I stopped AutoFS &amp; 
tried killing the remaining automount process. "kill 14986" didn't 
work; I needed "kill -9 14986". The following mounts remain:

wum:~# mount
[...]
automount(pid14986) on /var/autofs/net type autofs 
(rw,fd=5,pgrp=14986,minproto=2,maxproto=4)
tor:/home on /var/autofs/net/tor/home type nfs 
(rw,nosuid,nodev,hard,intr,addr=192.168.103.158)

&amp; I can't unmount them:

wum:~# umount /var/autofs/net/tor/home
umount: /var/autofs/net/tor/home: device is busy
umount: /var/autofs/net/tor/home: device is busy
wum:~# umount -f /var/autofs/net/tor/home
umount2: Device or resource busy
umount: /var/autofs/net/tor/home: Illegal seek
umount2: Device or resource busy
umount: /var/autofs/net/tor/home: device is busy
wum:~# umount /var/autofs/net
umount: /var/autofs/net: device is busy
umount: /var/autofs/net: device is busy
wum:~# umount -f /var/autofs/net
umount2: Device or resource busy
umount: automount(pid14986): not found
umount: /var/autofs/net: Illegal seek
umount2: Device or resource busy
umount: /var/autofs/net: device is busy

I triple checked that no process is using these mounts. How do I 
unmount them?

Thanks!

Jack



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW <a class="moz-txt-link-freetext" href="http://ad.doubleclick.net/clk;10740251;10262165;m">http://ad.doubleclick.net/clk;10740251;10262165;m</a>
_______________________________________________
NFS maillist  -  <a class="moz-txt-link-abbreviated" href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a>
<a class="moz-txt-link-freetext" href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a>
      </pre>
    </blockquote>
    <pre wrap="">


-------------------------------------------------------
This Newsletter Sponsored by: Macrovision 
For reliable Linux application installations, use the industry's leading
setup authoring tool, InstallShield X. Learn more and evaluate 
today. <a class="moz-txt-link-freetext" href="http://clk.atdmt.com/MSI/go/ins0030000001msi/direct/01/">http://clk.atdmt.com/MSI/go/ins0030000001msi/direct/01/</a>
_______________________________________________
NFS maillist  -  <a class="moz-txt-link-abbreviated" href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a>
<a class="moz-txt-link-freetext" href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a>

    </pre>
  </blockquote>
  <pre wrap=""><!---->


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
<a class="moz-txt-link-freetext" href="http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click">http://ads.osdn.com/?ad_id=5588&amp;alloc_id=12065&amp;op=click</a>
_______________________________________________
NFS maillist  -  <a class="moz-txt-link-abbreviated" href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a>
<a class="moz-txt-link-freetext" href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a>
  </pre>
</blockquote>
</body>
</html>



-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
