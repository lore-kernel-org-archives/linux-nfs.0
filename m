From: "Robert Rappaport" <robert.rappaport@gmail.com>
Subject: Re: [PATCH] locks: provide a file lease method enabling
	cluster-coherent leases
Date: Tue, 5 Jun 2007 18:04:57 -0400
Message-ID: <f0a71180706051504j712f7415vc82682e0958a2239@mail.gmail.com>
References: <OF3A5C7199.4DE8BA91-ON882572EE.006302AD-882572EE.0063A704@us.ibm.com>
	<1180808482.6687.30.camel@heimdal.trondhjem.org>
	<20070604135920.GA2233@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0190555937=="
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hvh98-0007Xv-81
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 15:04:58 -0700
Received: from mu-out-0910.google.com ([209.85.134.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hvh99-00050a-It
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 15:05:00 -0700
Received: by mu-out-0910.google.com with SMTP id w9so1984915mue
	for <nfs@lists.sourceforge.net>; Tue, 05 Jun 2007 15:04:57 -0700 (PDT)
In-Reply-To: <20070604135920.GA2233@fieldses.org>
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

--===============0190555937==
Content-Type: multipart/alternative;
	boundary="----=_Part_18899_15694204.1181081097336"

------=_Part_18899_15694204.1181081097336
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have had some previous communications with Bruce on these topics, and I am
generally pleased with the proposed modifications that are presented here.

I am working on a clustered file system and there is one small additional
modification that would be of great use to me.  That would be to export the
__setlease symbol.

In my implementation, my file system specific set_lease() function first
determines whether the granting of the requested lease on the given inode is
compatible with the cluster state of this inode, and then if it is, I simply
invoke the __setlease() routine and have the kernel build the associated
infrastructure.

Having this symbol globally available greatly simplifies things.

On 6/4/07, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Sat, Jun 02, 2007 at 02:21:22PM -0400, Trond Myklebust wrote:
> > Currently, the lease handling is done all in the VFS, and is done prior
> > to calling any filesystem operations. Bruce's break_lease() inode
> > operation allows the VFS to notify the filesystem that some operation is
> > going to be called that requires the lease to be broken.
> >
> > My point is that in doing so, you are not atomic with the operation that
> > requires the lease to be broken. Some different node may re-establish a
> > lease while we're calling back down into the filesystem to perform the
> > operation.
> > So I agree with you. The break_lease() inode operation isn't going to
> > work. The filesystem is going to have to figure out for itself when it
> > needs to notify other nodes that the lease needs breaking, and it needs
> > to figure out its own methods for ensuring atomicity.
>
> OK, I agree with you both, thanks for the explanations.
>
> It looks to me like there's probably a race in the existing code that
> will allow conflicting opens and leases to be granted simultaneously if
> the lease request is handled just after may_open() is called.  These
> checks at the beginning of __setlease() are an attempt to prevent that
> race:
>
>         if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
>                 goto out;
>         if ((arg == F_WRLCK)
>             && ((atomic_read(&dentry->d_count) > 1)
>                 || (atomic_read(&inode->i_count) > 1)))
>                 goto out;
>
> But, for example, in the case of a simultaneous write open and RDLCK
> lease request, I believe the call to setlease could come after the
> may_open() but before the call to get_write_access() that bumps
> i_writecount.
>
> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

------=_Part_18899_15694204.1181081097336
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have had some previous communications with Bruce on these topics, and
I am generally pleased with the proposed modifications that are
presented here.<br>
<br>
I am working on a clustered file system and there is one small
additional modification that would be of great use to me.&nbsp; That
would be to export the __setlease symbol.<br>
<br>
In my implementation, my file system specific set_lease() function
first determines whether the granting of the requested lease on the
given inode is compatible with the cluster state of this inode, and
then if it is, I simply invoke the __setlease() routine and have the
kernel build the associated infrastructure.<br>
<br>
Having this symbol globally available greatly simplifies things.<br><br><div><span class="gmail_quote">On 6/4/07, <b class="gmail_sendername">J. Bruce Fields</b> &lt;<a href="mailto:bfields@fieldses.org">bfields@fieldses.org
</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">On Sat, Jun 02, 2007 at 02:21:22PM -0400, Trond Myklebust wrote:<br>&gt; Currently, the lease handling is done all in the VFS, and is done prior
<br>&gt; to calling any filesystem operations. Bruce&#39;s break_lease() inode<br>&gt; operation allows the VFS to notify the filesystem that some operation is<br>&gt; going to be called that requires the lease to be broken.
<br>&gt;<br>&gt; My point is that in doing so, you are not atomic with the operation that<br>&gt; requires the lease to be broken. Some different node may re-establish a<br>&gt; lease while we&#39;re calling back down into the filesystem to perform the
<br>&gt; operation.<br>&gt; So I agree with you. The break_lease() inode operation isn&#39;t going to<br>&gt; work. The filesystem is going to have to figure out for itself when it<br>&gt; needs to notify other nodes that the lease needs breaking, and it needs
<br>&gt; to figure out its own methods for ensuring atomicity.<br><br>OK, I agree with you both, thanks for the explanations.<br><br>It looks to me like there&#39;s probably a race in the existing code that<br>will allow conflicting opens and leases to be granted simultaneously if
<br>the lease request is handled just after may_open() is called.&nbsp;&nbsp;These<br>checks at the beginning of __setlease() are an attempt to prevent that<br>race:<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if ((arg == F_RDLCK) &amp;&amp; (atomic_read(&amp;inode-&gt;i_writecount) &gt; 0))
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if ((arg == F_WRLCK)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&amp;&amp; ((atomic_read(&amp;dentry-&gt;d_count) &gt; 1)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;||
(atomic_read(&amp;inode-&gt;i_count) &gt; 1)))<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br><br>But, for example, in the case of a simultaneous write open and RDLCK<br>lease request, I believe the call to setlease could come after the
<br>may_open() but before the call to get_write_access() that bumps<br>i_writecount.<br><br>--b.<br>-<br>To unsubscribe from this list: send the line &quot;unsubscribe linux-fsdevel&quot; in<br>the body of a message to <a href="mailto:majordomo@vger.kernel.org">
majordomo@vger.kernel.org</a><br>More majordomo info at&nbsp;&nbsp;<a href="http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org/majordomo-info.html</a><br></blockquote></div><br>

------=_Part_18899_15694204.1181081097336--


--===============0190555937==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0190555937==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0190555937==--
