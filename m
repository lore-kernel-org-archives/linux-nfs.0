From: "Robert Rappaport" <robert.rappaport@gmail.com>
Subject: Re: [PATCH] locks: provide a file lease method enabling
	cluster-coherent leases
Date: Wed, 6 Jun 2007 14:43:22 -0400
Message-ID: <f0a71180706061143t1b4a4374qef319deac727815f@mail.gmail.com>
References: <OFB9D089FA.C0E6BE5A-ON882572F1.007D3720-882572F1.007E299C@us.ibm.com>
	<1181086828.6108.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1668745151=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hw0TZ-0001bZ-Cc
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 11:43:21 -0700
Received: from hu-out-0506.google.com ([72.14.214.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hw0Tc-0001Cx-14
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 11:43:24 -0700
Received: by hu-out-0506.google.com with SMTP id 28so137164hub
	for <nfs@lists.sourceforge.net>; Wed, 06 Jun 2007 11:43:22 -0700 (PDT)
In-Reply-To: <1181086828.6108.11.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1668745151==
Content-Type: multipart/alternative;
	boundary="----=_Part_28479_22607026.1181155402125"

------=_Part_28479_22607026.1181155402125
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

It appears that there is agreement that the functionality currently
implemented in __setlease() should be exported, even though the exported
name may not be __setlease().

That is just fine with me.

The question that I have now is when do you think it likely that these
changes get into the released code?  I hope that the plan is to get it there
fairly soon.

- Robert Rappaport

On 6/5/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Tue, 2007-06-05 at 15:56 -0700, Marc Eshel wrote:
> > Hi Bruce,
> > The file system does need to keep the local state up to date, like it
> does
> > with posix locks, so it might need to call __setlease(). The why we had
> it
> > before was that the call to the file system was done from outside of
> > setlease() and the file system was able to call setlease() which is
> > exported. Now that the call to the fs  moved into setlease() the file
> > system can not call it anymore so one possible solution would be to
> export
> > __setlease().
> > Marc.
>
> Please just make a vfs_setlease() which has the ability to call down
> into the filesystem and leave the exported setlease() as a generic
> method that can continue to be called by the filesystems themselves (and
> acts as a fallback for vfs_setlease()). That would be closer to the VFS
> naming conventions.
>
> Trond
>
>

------=_Part_28479_22607026.1181155402125
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

It appears that there is agreement that the functionality currently
implemented in __setlease() should be exported, even though the
exported name may not be __setlease().<br>
<br>
That is just fine with me.<br>
<br>
The question that I have now is when do you think it likely that these
changes get into the released code?&nbsp; I hope that the plan is to
get it there fairly soon.<br>
<br>- Robert Rappaport<br>
<br><div><span class="gmail_quote">On 6/5/07, <b class="gmail_sendername">Trond Myklebust</b> &lt;<a href="mailto:trond.myklebust@fys.uio.no">trond.myklebust@fys.uio.no</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Tue, 2007-06-05 at 15:56 -0700, Marc Eshel wrote:<br>&gt; Hi Bruce,<br>&gt; The file system does need to keep the local state up to date, like it does<br>&gt; with posix locks, so it might need to call __setlease(). The why we had it
<br>&gt; before was that the call to the file system was done from outside of<br>&gt; setlease() and the file system was able to call setlease() which is<br>&gt; exported. Now that the call to the fs&nbsp;&nbsp;moved into setlease() the file
<br>&gt; system can not call it anymore so one possible solution would be to export<br>&gt; __setlease().<br>&gt; Marc.<br><br>Please just make a vfs_setlease() which has the ability to call down<br>into the filesystem and leave the exported setlease() as a generic
<br>method that can continue to be called by the filesystems themselves (and<br>acts as a fallback for vfs_setlease()). That would be closer to the VFS<br>naming conventions.<br><br>Trond<br><br></blockquote></div><br>

------=_Part_28479_22607026.1181155402125--


--===============1668745151==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1668745151==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1668745151==--
