From: "Nida M" <nidajm@gmail.com>
Subject: Re: On NFS mounted file system access time not updated
Date: Mon, 19 Jun 2006 13:20:24 +0530
Message-ID: <b01966ec0606190050r48757400x98945f58f1032283@mail.gmail.com>
References: <b01966ec0606170504p1575f325y560aa3b764dc47a2@mail.gmail.com>
	<1150660000.6771.189.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1258285474=="
Cc: neil@brown.name, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FsEWg-0001Mh-6M
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 00:50:26 -0700
Received: from nz-out-0102.google.com ([64.233.162.204])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FsEWg-0007yO-4r
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 00:50:26 -0700
Received: by nz-out-0102.google.com with SMTP id x7so1136123nzc
	for <nfs@lists.sourceforge.net>; Mon, 19 Jun 2006 00:50:24 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1150660000.6771.189.camel@lade.trondhjem.org>
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

--===============1258285474==
Content-Type: multipart/alternative;
	boundary="----=_Part_115793_20413496.1150703424118"

------=_Part_115793_20413496.1150703424118
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks for the reply.

 >>If the client reads the file from its own cache the atime does not get
>>updated on the server.

 This was the case in my test program. I am reading the same 4KB block all
the time.

Now i have modified it  such that, the client does the read of 1KB at
first,later on the reading increased by 1KB.

And the results are:
atime updated  for the first read  and the  time elapsed 1 sec.
 for the remaining read ATIME is updated  only after  60 sec.


How to make sure that the atime is updated for every read.

Thanks in advance.



~Nida








On 6/19/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Sat, 2006-06-17 at 17:34 +0530, Nida M wrote:
> > Hi
> >
> > I am phasing a problem on MIPS platform for kernel 2.6.16 that,
> > on NFS mounted file system the atime is not getting updated.
> >
> > To test this i have written a test program ,in which I am doing a
> > read(),
> > and then I do a stat() to check the changed attribute of the file
> > being read.
> > But I found the access time [atime]  is not getting updated..
> >
> > For 2.6 kernel has any patch is released to fix this problem ..?
> > I need to fix this problem .. Can Anybody help me in this..??
>
> If the client reads the file from its own cache the atime does not get
> updated on the server.
>
> Trond
>
>

------=_Part_115793_20413496.1150703424118
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<div>Thanks for the reply.</div>
<div>&nbsp;</div>
<div>&nbsp;&gt;&gt;If the client reads the file from its own cache the atime does not get<br>&gt;&gt;updated on the server.</div>
<div>&nbsp;</div>
<div>
<div>This was the case in my test program. I am reading the same 4KB block all the time.</div>
<div>&nbsp;</div>
<div>Now i have modified&nbsp;it&nbsp; such that, the client does the read of 1KB at first,later on the reading&nbsp;increased by 1KB.</div>
<div>&nbsp;</div>
<div>And the results are:</div>
<div>atime updated&nbsp; for the first read&nbsp; and the &nbsp;time elapsed 1 sec.</div>
<div>
<div>for the remaining read ATIME is updated&nbsp; only&nbsp;after&nbsp;&nbsp;60 sec.</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>How to make sure that the atime is updated for every read.</div>
<div>&nbsp;</div>
<div>Thanks in advance.</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>~Nida</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>
<div>&nbsp;</div></div></div></div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div><br>&nbsp;</div>
<div><span class="gmail_quote">On 6/19/06, <b class="gmail_sendername">Trond Myklebust</b> &lt;<a href="mailto:trond.myklebust@fys.uio.no">trond.myklebust@fys.uio.no</a>&gt; wrote:</span>
<blockquote class="gmail_quote" style="PADDING-LEFT: 1ex; MARGIN: 0px 0px 0px 0.8ex; BORDER-LEFT: #ccc 1px solid">On Sat, 2006-06-17 at 17:34 +0530, Nida M wrote:<br>&gt; Hi<br>&gt;<br>&gt; I am phasing a problem on MIPS platform for kernel 
2.6.16 that,<br>&gt; on NFS mounted file system the atime is not getting updated.<br>&gt;<br>&gt; To test this i have written a test program ,in which I am doing a<br>&gt; read(),<br>&gt; and then I do a stat() to check the changed attribute of the file
<br>&gt; being read.<br>&gt; But I found the access time [atime]&nbsp;&nbsp;is not getting updated..<br>&gt;<br>&gt; For 2.6 kernel has any patch is released to fix this problem ..?<br>&gt; I need to fix this problem .. Can Anybody help me in this..??
<br><br>If the client reads the file from its own cache the atime does not get<br>updated on the server.<br><br>Trond<br><br></blockquote></div><br>

------=_Part_115793_20413496.1150703424118--


--===============1258285474==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1258285474==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1258285474==--
