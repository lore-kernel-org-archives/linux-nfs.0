From: Christopher Huhn <C.Huhn@gsi.de>
Subject: Re: executable but not readable
Date: Mon, 29 Mar 2004 13:35:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <406809FE.5040100@gsi.de>
References: <40631E32.1020707@gsi.de>	 <1080239856.2584.18.camel@lade.trondhjem.org>  <40640A7E.5040601@gsi.de> <1080328671.2480.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------010507050206010302060701"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7v3X-0008Rl-3p
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 03:35:51 -0800
Received: from lxmta2.gsi.de ([140.181.67.43])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B7v3W-0005d4-Kl
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 03:35:50 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1080328671.2480.23.camel@lade.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------010507050206010302060701
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi again,

Trond Myklebust wrote:

>The point in the RFC is that the server should be looking
>at both the "executable" and the "read" bits when deciding whether or
>not to grant read access to the client.
>...
>  
>
>However if you really want to prevent OTHER+GROUP from reading and
>executing your shell scripts, then "chmod 500 /bin/ls.sh" is your
>simplest solution. That does the same thing on both the local and remote
>filesystems.
>  
>
I'm totally aware of the fact that this approach to enhance the security 
is dysfunctional and pretty lame [sigh].
Anyway, it was done like this in ancient days - and never worked but 
never did any harm either.

Now it's not working anymore and the only thing changed is the kernel.
So to get back to my initial question: *Is this a NFS bug?* Or has maybe 
something else changed  in the kernel?

Regards,
    Christopher

--------------010507050206010302060701
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Hi again,<br>
<br>
Trond Myklebust wrote:
<blockquote cite="mid1080328671.2480.23.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap=""><!---->The point in the RFC is that the server should be looking
at both the "executable" and the "read" bits when deciding whether or
not to grant read access to the client.
...
  </pre>
</blockquote>
<blockquote cite="mid1080328671.2480.23.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap="">However if you really want to prevent OTHER+GROUP from reading and
executing your shell scripts, then "chmod 500 /bin/ls.sh" is your
simplest solution. That does the same thing on both the local and remote
filesystems.
  </pre>
</blockquote>
I'm totally aware of the fact that this approach to enhance the
security is dysfunctional and pretty lame [sigh].<br>
Anyway, it was done like this in ancient days - and never worked but
never did any harm either.<br>
<br>
Now it's not working anymore and the only thing changed is the kernel.<br>
So to get back to my initial question: *Is this a NFS bug?* Or has
maybe something else changed&nbsp; in the kernel?<br>
<br>
Regards,<br>
&nbsp;&nbsp;&nbsp; Christopher<br>
</body>
</html>

--------------010507050206010302060701--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
