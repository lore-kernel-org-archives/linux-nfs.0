From: InsaneToucan <insanetoucan@gmail.com>
Subject: Re: mounting tmpfs: permission denied
Date: Mon, 2 Apr 2007 11:14:06 -0500
Message-ID: <1c9889d10704020914r780feb72hd9e0199bdcc2e985@mail.gmail.com>
References: <1c9889d10703301416s6c1a8b38h54d653036d9ed1cf@mail.gmail.com>
	<17936.7012.831282.944994@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0430764187=="
Cc: nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYPAW-0005kb-GG
	for nfs@lists.sourceforge.net; Mon, 02 Apr 2007 09:14:08 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYPAX-0007yE-Bm
	for nfs@lists.sourceforge.net; Mon, 02 Apr 2007 09:14:10 -0700
Received: by ug-out-1314.google.com with SMTP id z38so1947297ugc
	for <nfs@lists.sourceforge.net>; Mon, 02 Apr 2007 09:14:07 -0700 (PDT)
In-Reply-To: <17936.7012.831282.944994@notabene.brown>
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

--===============0430764187==
Content-Type: multipart/alternative;
	boundary="----=_Part_118119_25505154.1175530446038"

------=_Part_118119_25505154.1175530446038
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

That worked, thanks for the help.

On 4/1/07, Neil Brown <neilb@suse.de> wrote:
>
> On Friday March 30, insanetoucan@gmail.com wrote:
> > Hello,
> >
> > $ cat /etc/exports
> > /pu 10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)
> > /tmpfs 10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)
>
> You need 'fsid=something' for /tmpfs.  As there is no device nfsd
> cannot use the device number in the filehandle, so you need to give it
> a number to use to identify that filesystem.
>
> I really should do something about getting an error message out of
> exportfs in this case.... or at least out of mountd.
>
> NeilBrown
>

------=_Part_118119_25505154.1175530446038
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

That worked, thanks for the help.<br><br><div><span class="gmail_quote">On 4/1/07, <b class="gmail_sendername">Neil Brown</b> &lt;<a href="mailto:neilb@suse.de">neilb@suse.de</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Friday March 30, <a href="mailto:insanetoucan@gmail.com">insanetoucan@gmail.com</a> wrote:<br>&gt; Hello,<br>&gt;<br>&gt; $ cat /etc/exports<br>&gt; /pu <a href="http://10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)">
10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)</a><br>&gt; /tmpfs <a href="http://10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)">10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)</a>
<br><br>You need &#39;fsid=something&#39; for /tmpfs.&nbsp;&nbsp;As there is no device nfsd<br>cannot use the device number in the filehandle, so you need to give it<br>a number to use to identify that filesystem.<br><br>I really should do something about getting an error message out of
<br>exportfs in this case.... or at least out of mountd.<br><br>NeilBrown<br></blockquote></div><br>

------=_Part_118119_25505154.1175530446038--


--===============0430764187==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0430764187==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0430764187==--
