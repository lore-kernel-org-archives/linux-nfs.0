From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 09:58:00 -0800
Message-ID: <9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1944205665=="
Cc: Peter Astrand <astrand@cendio.se>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpqAi-00060O-59
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 09:58:08 -0800
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GpqAh-0000no-14
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 09:58:09 -0800
Received: by nf-out-0910.google.com with SMTP id c31so5158681nfb
	for <nfs@lists.sourceforge.net>; Thu, 30 Nov 2006 09:58:00 -0800 (PST)
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20061130102238.GA11918@suse.de>
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

--===============1944205665==
Content-Type: multipart/alternative;
	boundary="----=_Part_13957_8846481.1164909480114"

------=_Part_13957_8846481.1164909480114
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Olaf

So this version of unfsd would fork several processes and there would be
some dispatching process to hand RPC requests to them? I assume these are
not multiple daemons invoked from the shell. The unfsd version available for
download seems to be strictly single process, and doesn't seem to be doing
this.

And what happens if multiple processes handle writes on behalf of different
clients to the same file? I just want to make sure the 8 process server can
handle what ever the clients do i.e lock, read, write etc. Presumably there
are inefficiencies, of course such as independent file handle caches within
each process and not much sharing between them.

Murali

On 11/30/06, Olaf Kirch <okir@suse.de> wrote:
>
> On Thu, Nov 30, 2006 at 11:00:25AM +0100, Peter Astrand wrote:
> > > Has anyone attempted to speedup concurrently handling many client NFS
> > > requests in unfsd? Any experience regarding multi-threading or running
> > > multiple processes within unfsd? Any do's and don'ts?
> >
> > This is an interesting topic. I guess it depends a lot on which RPC
> > library you are using. The "normal" ONC RPC implementation, found in
> glibc
> > for example, is as far as I know not thread safe. This might be a
> problem.
> > Correct me if I'm wrong.
>
> unfsd was able to run several process in parallel since I think 1998. Note
> it's multi-process not multithread, so it's a tad inefficient - but I
> haven't heard of any problems in that area.  unfsd was running on some
> machines in the Suse R&D network as late as a few months ago, with 8
> processes in parallel.
>
> Olaf
> --
> Walks like a duck. Quacks like a duck. Must be a chicken.
>

------=_Part_13957_8846481.1164909480114
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Olaf<br><br>So this version of unfsd would fork several processes and there would be some dispatching process to hand RPC requests to them? I assume these are not multiple daemons invoked from the shell. The unfsd version available for download seems to be strictly single process, and doesn't seem to be doing this.
<br><br>And what happens if multiple processes handle writes on behalf of different clients to the same file? I just want to make sure the 8 process server can handle what ever the clients do i.e lock, read, write etc. Presumably there are inefficiencies, of course such as independent file handle caches within each process and not much sharing between them.
<br><br>Murali<br><br><div><span class="gmail_quote">On 11/30/06, <b class="gmail_sendername">Olaf Kirch</b> &lt;<a href="mailto:okir@suse.de">okir@suse.de</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Thu, Nov 30, 2006 at 11:00:25AM +0100, Peter Astrand wrote:<br>&gt; &gt; Has anyone attempted to speedup concurrently handling many client NFS<br>&gt; &gt; requests in unfsd? Any experience regarding multi-threading or running
<br>&gt; &gt; multiple processes within unfsd? Any do's and don'ts?<br>&gt;<br>&gt; This is an interesting topic. I guess it depends a lot on which RPC<br>&gt; library you are using. The &quot;normal&quot; ONC RPC implementation, found in glibc
<br>&gt; for example, is as far as I know not thread safe. This might be a problem.<br>&gt; Correct me if I'm wrong.<br><br>unfsd was able to run several process in parallel since I think 1998. Note<br>it's multi-process not multithread, so it's a tad inefficient - but I
<br>haven't heard of any problems in that area.&nbsp;&nbsp;unfsd was running on some<br>machines in the Suse R&amp;D network as late as a few months ago, with 8<br>processes in parallel.<br><br>Olaf<br>--<br>Walks like a duck. Quacks like a duck. Must be a chicken.
<br></blockquote></div><br>

------=_Part_13957_8846481.1164909480114--


--===============1944205665==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1944205665==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1944205665==--
