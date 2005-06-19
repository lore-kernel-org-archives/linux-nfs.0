From: Oded Maimon <oded.maimon@gmail.com>
Subject: Re: nfs break
Date: Sun, 19 Jun 2005 23:08:48 +0200
Message-ID: <42B5DEE0.5070600@gmail.com>
References: <42B5BB6F.9030104@gmail.com> <1119208054.11291.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/html; charset=UTF-8
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1119208054.11291.21.camel@lade.trondhjem.org>
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
  <meta content="text/html;charset=UTF-8" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" dir="ltr" text="#000000">
<p style="margin-top: 0cm; margin-bottom: 0cm;" dir="ltr"><br>
</p>
<br>
Trond Myklebust wrote:
<blockquote cite="mid1119208054.11291.21.camel@lade.trondhjem.org"
 type="cite" dir="ltr">
  <pre wrap="">su den 19.06.2005 Klokka 20:37 (+0200) skreiv Oded Maimon:
  </pre>
  <blockquote type="cite">
    <pre wrap="">Hi,

is there any way to make nfs-client create more informative logs?

somthing like levels of logs?
    </pre>
  </blockquote>
  <pre wrap=""><!---->
The only logging that the current NFS client supports is the information
provided by "nfsstat".

It is also possible to enable selective debug tracing in the case of
client bugs, but those traces were not designed with system
administration in mind, and so are unlikely to be very useful.

Cheers,
  Trond


  </pre>
</blockquote>
thanks, that will be very helpful, <br>
can you please tell me how can i enable the debug tracing, just to see
what i can get from that?<br>
</body>
</html>


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
