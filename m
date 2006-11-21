From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: Re: Disabling NFS client caching
Date: Tue, 21 Nov 2006 11:54:18 -0800
Message-ID: <9c8209a10611211154p5091f0c2l5379989d611a31f0@mail.gmail.com>
References: <9c8209a10611201824h608c11f3s5bf9957c4ce0abd4@mail.gmail.com>
	<1164084864.6377.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1194319422=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmbhE-0001MH-5c
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 11:54:20 -0800
Received: from nf-out-0910.google.com ([64.233.182.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmbhE-0005ll-3h
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 11:54:21 -0800
Received: by nf-out-0910.google.com with SMTP id c31so424423nfb
	for <nfs@lists.sourceforge.net>; Tue, 21 Nov 2006 11:54:18 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1164084864.6377.30.camel@lade.trondhjem.org>
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

--===============1194319422==
Content-Type: multipart/alternative;
	boundary="----=_Part_46166_25447566.1164138858162"

------=_Part_46166_25447566.1164138858162
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks for the suggestion. I tried the O_DIRECT option with O_RDONLY, and i
am still seeing a lot of reads not hitting the server, looks like they are
being handled locally still. I've got the sizes and addresses page aligned.
Is there anything else that needs to be done to bypass the caching?

Thx,
Murali

On 11/20/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Mon, 2006-11-20 at 18:24 -0800, Murali Bashyam wrote:
> > Hi
> >
> > Is there a way to disable Linux NFS client data caching (NOT
> > attributes)?
>
> 'man 2 open'. Read all about O_DIRECT.
>
> Trond
>
>

------=_Part_46166_25447566.1164138858162
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br>Thanks for the suggestion. I tried the O_DIRECT option with O_RDONLY, and i am still seeing a lot of reads not hitting the server, looks like they are being handled locally still. I've got the sizes and addresses page aligned. Is there anything else that needs to be done to bypass the caching?
<br><br>Thx,<br>Murali<br><br><div><span class="gmail_quote">On 11/20/06, <b class="gmail_sendername">Trond Myklebust</b> &lt;<a href="mailto:trond.myklebust@fys.uio.no">trond.myklebust@fys.uio.no</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Mon, 2006-11-20 at 18:24 -0800, Murali Bashyam wrote:<br>&gt; Hi<br>&gt;<br>&gt; Is there a way to disable Linux NFS client data caching (NOT<br>&gt; attributes)?<br><br>'man 2 open'. Read all about O_DIRECT.<br><br>Trond
<br><br></blockquote></div><br>

------=_Part_46166_25447566.1164138858162--


--===============1194319422==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1194319422==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1194319422==--
