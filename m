From: Rosario Turrisi <turrisi@pd.infn.it>
Subject: Re: action "debugfs-like" through nfs?
Date: Wed, 23 Jul 2003 17:15:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F1EA68C.7020700@pd.infn.it>
References: <3F1E892B.8020508@pd.infn.it> <shs1xwhtgzv.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------040700060608080704040600"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from is01.lnl.infn.it ([192.135.30.245])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19fLL2-00020H-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Jul 2003 08:15:32 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs1xwhtgzv.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------040700060608080704040600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

... because raidtec does not give the password to customers...
I am afraid, and you confirm, that the only choice is their  intervention...
Thanks,
         Rosario

Trond Myklebust wrote:

>>>>>>" " == Rosario Turrisi <turrisi@pd.infn.it> writes:
>>>>>>            
>>>>>>
>
>     > Hi, I have a fileserver from Raidtec which uses ext2
>     > filesystems.  Due to a double (!!!) disk failure, I had the
>     > strange behaviour that a directory is seen as a whole file,
>     > with strange attributes, like "?r--r-sr-T" and changed
>     > owner/group.  I believe that an operation like "debugfs" could
>     > fix the problem, but it cannot be done (it seems) on an
>     > nfs-mounted filesystem (I cannot enter the fileserver system as
>     > it is "raidtec-copyrighted").  Any suggestion very very
>     > welcome.  Cheers,
>
>Errr... Why is fixing it on the server itself (where "debugfs" is more
>likely to work) not an option?
>
>The NFS protocol has no support for doing low-level disk ioctls on the
>server so you can forget doing this sort of thing on the client.
>
>Cheers,
>  Trond
>
>
>
>  
>

--------------040700060608080704040600
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
  <title></title>
</head>
<body text="#000000" bgcolor="#ffffff">
... because raidtec does not give the password to customers...<br>
I am afraid, and you confirm, that the only choice is their&nbsp;
intervention...<br>
Thanks,<br>
&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Rosario<br>
<br>
Trond Myklebust wrote:<br>
<blockquote type="cite" cite="midshs1xwhtgzv.fsf@charged.uio.no">
  <blockquote type="cite">
    <blockquote type="cite">
      <blockquote type="cite">
        <blockquote type="cite">
          <blockquote type="cite">
            <pre wrap="">" " == Rosario Turrisi <a class="moz-txt-link-rfc2396E" href="mailto:turrisi@pd.infn.it">&lt;turrisi@pd.infn.it&gt;</a> writes:
            </pre>
          </blockquote>
        </blockquote>
      </blockquote>
    </blockquote>
  </blockquote>
  <pre wrap=""><!---->
     &gt; Hi, I have a fileserver from Raidtec which uses ext2
     &gt; filesystems.  Due to a double (!!!) disk failure, I had the
     &gt; strange behaviour that a directory is seen as a whole file,
     &gt; with strange attributes, like "?r--r-sr-T" and changed
     &gt; owner/group.  I believe that an operation like "debugfs" could
     &gt; fix the problem, but it cannot be done (it seems) on an
     &gt; nfs-mounted filesystem (I cannot enter the fileserver system as
     &gt; it is "raidtec-copyrighted").  Any suggestion very very
     &gt; welcome.  Cheers,

Errr... Why is fixing it on the server itself (where "debugfs" is more
likely to work) not an option?

The NFS protocol has no support for doing low-level disk ioctls on the
server so you can forget doing this sort of thing on the client.

Cheers,
  Trond



  </pre>
</blockquote>
</body>
</html>

--------------040700060608080704040600--



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
