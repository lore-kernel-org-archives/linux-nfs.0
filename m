From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: Re: intercepting NFS RPC requests
Date: Tue, 7 Nov 2006 12:36:35 -0800
Message-ID: <9c8209a10611071236v6f4bc895h7fe5fe257c1b5629@mail.gmail.com>
References: <9c8209a10611071050p475a2cf1y6656153a4b6a24e7@mail.gmail.com>
	<20061107193638.GD11346@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0305357452=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhXgT-0003V6-I8
	for nfs@lists.sourceforge.net; Tue, 07 Nov 2006 12:36:38 -0800
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GhXgT-0005l2-Ec
	for nfs@lists.sourceforge.net; Tue, 07 Nov 2006 12:36:38 -0800
Received: by nf-out-0910.google.com with SMTP id c31so360506nfb
	for <nfs@lists.sourceforge.net>; Tue, 07 Nov 2006 12:36:36 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061107193638.GD11346@fieldses.org>
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

--===============0305357452==
Content-Type: multipart/alternative;
	boundary="----=_Part_15704_24682583.1162931795734"

------=_Part_15704_24682583.1162931795734
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 11/7/06, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Nov 07, 2006 at 10:50:54AM -0800, Murali Bashyam wrote:
> > Is there a feature on the linux v3 or v4 NFS server to allow a process
> to
> > intercept the NFS RPC requests for file operations (open, close, read,
> write
> > etc) and handle them in user space?
>
> No.
>
> > If so, can these be handled asynchronously?
> >
> > Alternatively, if this is not possible, is this achievable through VFS
> > i.ehave a process create and register a file system through VFS and
> > export it
> > through NFS? Now when the server handles a client's file operation, it
> goes
> > through VFS and ends up with that vector registered by that process?
>
> No. You could modify fuse to support nfsd, or you could write a
> userspace NFS server (or modify an existing server).


Isn't it simpler (and potentially inefficient)  to export the NFS mount
point as a FUSE filesystem?

Murali

--b.
>

------=_Part_15704_24682583.1162931795734
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div><span class="gmail_quote">On 11/7/06, <b class="gmail_sendername">J. Bruce Fields</b> &lt;<a href="mailto:bfields@fieldses.org">bfields@fieldses.org</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Tue, Nov 07, 2006 at 10:50:54AM -0800, Murali Bashyam wrote:<br>&gt; Is there a feature on the linux v3 or v4 NFS server to allow a process to<br>&gt; intercept the NFS RPC requests for file operations (open, close, read, write
<br>&gt; etc) and handle them in user space?<br><br>No.<br><br>&gt; If so, can these be handled asynchronously?<br>&gt;<br>&gt; Alternatively, if this is not possible, is this achievable through VFS<br>&gt; i.ehave a process create and register a file system through VFS and
<br>&gt; export it<br>&gt; through NFS? Now when the server handles a client's file operation, it goes<br>&gt; through VFS and ends up with that vector registered by that process?<br><br>No. You could modify fuse to support nfsd, or you could write a
<br>userspace NFS server (or modify an existing server).</blockquote><div><br>Isn't it simpler (and potentially inefficient)&nbsp; to export the NFS mount point as a FUSE filesystem?<br><br>Murali<br></div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
--b.<br></blockquote></div><br>

------=_Part_15704_24682583.1162931795734--


--===============0305357452==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0305357452==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0305357452==--
