From: "Warren Beldad" <advisory22@gmail.com>
Subject: Re: large files on nfs share
Date: Mon, 4 Dec 2006 16:39:28 +0800
Message-ID: <b5ba2f6a0612040039o46ddf382k86010a443baf8a69@mail.gmail.com>
References: <941ca8f70612031233i1ccc8fddq3e27a9610f5b481a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0445126223=="
Cc: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gr9MG-0000k7-7n
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 00:39:28 -0800
Received: from wx-out-0506.google.com ([66.249.82.224])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gr9MH-00016P-CX
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 00:39:29 -0800
Received: by wx-out-0506.google.com with SMTP id i30so5469370wxd
	for <nfs@lists.sourceforge.net>; Mon, 04 Dec 2006 00:39:28 -0800 (PST)
To: "Allan Wilson" <allanwilson@gmail.com>
In-Reply-To: <941ca8f70612031233i1ccc8fddq3e27a9610f5b481a@mail.gmail.com>
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

--===============0445126223==
Content-Type: multipart/alternative;
	boundary="----=_Part_31167_998239.1165221568051"

------=_Part_31167_998239.1165221568051
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

have you tried copying that file into your local disk. can it copy the whole
file?
whats the error? something like the file is no longer there or the network
is unavailable....

On 12/4/06, Allan Wilson <allanwilson@gmail.com> wrote:
>
> I am running a nfs server on Ubuntu Edgy and have some large movies stored
> on that box. One is 4.9GB and the other is 5.9GB. I can play the movies on
> another linux box by mounting the share or on a windows computer using
> "Windows Services for Unix" but no matter what I choose I can only see about
> 14minutes of each video before it tells me end of file. I have tried
> different players xine and mplayer both do the same thing. It has to be a
> nfs server setting but I don't know what it is. Any ideas?
>
> Allan
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share
> your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>

------=_Part_31167_998239.1165221568051
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

have you tried copying that file into your local disk. can it copy the whole file?<br>whats the error? something like the file is no longer there or the network is unavailable....<br><br><div><span class="gmail_quote">On 12/4/06, 
<b class="gmail_sendername">Allan Wilson</b> &lt;<a href="mailto:allanwilson@gmail.com">allanwilson@gmail.com</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
I am running a nfs server on Ubuntu Edgy and have some large movies stored on that box. One is 4.9GB and the other is 5.9GB. I can play the movies on another linux box by mounting the share or on a windows computer using &quot;Windows Services for Unix&quot; but no matter what I choose I can only see about 14minutes of each video before it tells me end of file. I have tried different players xine and mplayer both do the same thing. It has to be a nfs server setting but I don't know what it is. Any ideas?
<br><span class="sg"><br>Allan<br>

</span><br>-------------------------------------------------------------------------<br>Take Surveys. Earn Cash. Influence the Future of IT<br>Join SourceForge.net's Techsay panel and you'll get the chance to share your<br>
opinions on IT &amp; business topics through brief surveys - and earn cash<br><a onclick="return top.js.OpenExtLink(window,event,this)" href="http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV" target="_blank">
http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV</a><br><br>_______________________________________________<br>NFS maillist &nbsp;- &nbsp;<a onclick="return top.js.OpenExtLink(window,event,this)" href="mailto:NFS@lists.sourceforge.net">
NFS@lists.sourceforge.net</a><br><a onclick="return top.js.OpenExtLink(window,event,this)" href="https://lists.sourceforge.net/lists/listinfo/nfs" target="_blank">https://lists.sourceforge.net/lists/listinfo/nfs</a><br><br>
<br></blockquote></div><br>

------=_Part_31167_998239.1165221568051--


--===============0445126223==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0445126223==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0445126223==--
