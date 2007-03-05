From: Dan Goetzman <dan_goetzman@bmc.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Mon, 05 Mar 2007 15:54:30 -0600
Message-ID: <45EC9196.40108@bmc.com>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1829888789=="
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOL8o-0006SL-Nf
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 13:54:46 -0800
Received: from sky.bmc.com ([198.207.223.240] helo=babbler.bmc.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOL8p-0003ZW-Hl
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 13:54:49 -0800
In-Reply-To: <1173130678.6315.7.camel@heimdal.trondhjem.org>
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

--===============1829888789==
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=us-ascii" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
<br>
&nbsp;I noticed the same problem at my site. fsid's in readdirplus on the
Tru64 server not being the same as other NFS procedures returned by the
Tru64 NFS server. I was able to see this in my network trace. And
disabling READDIRPLUS allowed everything to work again.<br>
<br>
&nbsp;This "32bitclients" NFS export option, you sure this is a Tru64 NFS
server feature?<br>
<br>
&nbsp;I added this option to my NFS export on the Tru64 NFS server, but
still have the same problem. I assume Tru64 is ignoring this NFS export
option?<br>
&nbsp;I have seen this NFS export option on SGI and OSX servers. If Tru64
supports 32bitclients, it is not documented that I could find.<br>
<br>
-Dan<br>
<br>
Trond Myklebust wrote:
<blockquote cite="mid1173130678.6315.7.camel@heimdal.trondhjem.org"
 type="cite">
  <pre wrap="">On Mon, 2007-03-05 at 15:35 -0500, Steve Dickson wrote:
  </pre>
  <blockquote type="cite">
    <pre wrap="">Over the last new months, I've been getting beaten up
about the fact the Fedora Core clients (FC5 and FC6)
no loner works with Tru64 server. The problem is
accessing mounted directories would fail with -ENOTDIR.
Similar to:

# ls /mnt/alpha/doc
/bin/ls: cannot open directory /mnt/alpha/doc: Not a directory

After months of floundering around looking at ethereal
traces and such, I actually was able to trace down a
Tru64 server to test against (thanks you very much HP!).

Low and behold... it turns not to be a Linux client
bug at all... but only Linux clients failed because
they seem to actually care what fsids are being returned.

The problem is this: Tru64 server exporting Advfs fileystems
return sign extend fsids in most but not all NFS procedures.

Meaning most fattrs returned by the server have a fsid of:
     fsid: 0xffffffff8419f8d5

but in some procs (like READDIRPLUS) the fsid is
     fsid: 0x000000008419f8d5

Which is _clearly_ wrong and does not happen with UFS
exports on the same server.

So its my contention that Tru64 has been broken forever
since only Linux clients fail, which started due to the
following patch that went into 2.6.12:
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Sorry, but I really do not like the idea of fixing server bugs in the
Linux client, and particularly not in generic code like this.

As far as I understood, this was a direct consequence of using the
32bitclients export option to work around the old issues with 64-bit
cookies on readdir. Is there really a need for this option now that
we've ensured that readdir cookies are no longer exported to userland?

Cheers
  Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT &amp; business topics through brief surveys-and earn cash
<a class="moz-txt-link-freetext" href="http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV">http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV</a>
_______________________________________________
NFS maillist  -  <a class="moz-txt-link-abbreviated" href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a>
<a class="moz-txt-link-freetext" href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a>

  </pre>
</blockquote>
</body>
</html>


--===============1829888789==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1829888789==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1829888789==--
