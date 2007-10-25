From: Prasad P <pvp@us.ibm.com>
Subject: Re: [PATCH] Fix incorrect assignment
Date: Thu, 25 Oct 2007 10:26:14 -0500
Message-ID: <OF5B1D195B.8B37E3EE-ON8725737F.00547AB2-8625737F.0054CCF1@us.ibm.com>
References: <20071024205736.GL29830@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2025350691=="
Cc: nfs-bounces@lists.sourceforge.net, nfs@lists.sourceforge.net,
	smfltc@us.ibm.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <20071024205736.GL29830@fieldses.org>
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

--===============2025350691==
Content-type: multipart/alternative;
	Boundary="0__=08BBF9ECDFC7FC228f9e8a93df938690918c08BBF9ECDFC7FC22"
Content-Disposition: inline

--0__=08BBF9ECDFC7FC228f9e8a93df938690918c08BBF9ECDFC7FC22
Content-type: text/plain; charset=US-ASCII

nfs-bounces@lists.sourceforge.net wrote on 10/24/2007 03:57:36 PM:

> On Wed, Oct 24, 2007 at 03:14:32PM -0500, Prasad P wrote:
> >
> >
> > Dereferenced pointer "dentry" without checking and assigned to inode
> > in the declaration.
>
> Seems reasonable, but: looking at nfsd_dispatch(), it appears that the
> encode function is never called in this case (since rq_vers == 2 and
> nfsacld_proc_getacl() would have returned an error if it couldn't find a
> dentry).  Am I missing something?  Do you have a test case?
>
> --b.

No, I don't have a test case.  This error was found by coverity scan.

After declaration of the variables, we actually check the dentry and
dentry->d_inode, and if they are not NULL, assign dentry->d_inode to inode
variable.

if (dentry == NULL || dentry->d_inode == NULL)
      return 0;
inode = dentry->d_inode;

>
>
> >
> > Cc: Steve French <smfltc@us.ibm.com>
> > Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
> > ---
> >
> > diff -uprN a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> > --- a/fs/nfsd/nfs2acl.c 2007-10-09 15:31:38.000000000 -0500
> > +++ b/fs/nfsd/nfs2acl.c 2007-10-24 14:03:13.000000000 -0500
> > @@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st
> >             struct nfsd3_getaclres *resp)
> >  {
> >       struct dentry *dentry = resp->fh.fh_dentry;
> > -     struct inode *inode = dentry->d_inode;
> > +     struct inode *inode;
> >       struct kvec *head = rqstp->rq_res.head;
> >       unsigned int base;
> >       int n;
> > --
> > Thanks.
> >
> > Regards,
> > Prasad Potluri
> > email: pvp at-sign us dot ibm dot com
> >
-------------------------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc.
> > Still grepping through log files to find problems?  Stop.
> > Now Search log events and configuration files using AJAX and a browser.
> > Download your FREE copy of Splunk now >> http://get.splunk.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
>
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
Thanks.

Regards,
Prasad Potluri
email: pvp at-sign us dot ibm dot com
--0__=08BBF9ECDFC7FC228f9e8a93df938690918c08BBF9ECDFC7FC22
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>nfs-bounces@lists.sourceforge.net wrote on 10/24/2007 03:57:36 PM:<br>
<br>
&gt; On Wed, Oct 24, 2007 at 03:14:32PM -0500, Prasad P wrote:<br>
&gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; Dereferenced pointer &quot;dentry&quot; without checking and assigned to inode<br>
&gt; &gt; in the declaration.<br>
&gt; <br>
&gt; Seems reasonable, but: looking at nfsd_dispatch(), it appears that the<br>
&gt; encode function is never called in this case (since rq_vers == 2 and<br>
&gt; nfsacld_proc_getacl() would have returned an error if it couldn't find a<br>
&gt; dentry). &nbsp;Am I missing something? &nbsp;Do you have a test case?<br>
&gt; <br>
&gt; --b.<br>
</tt><br>
<tt>No, I don't have a test case. &nbsp;This error was found by coverity scan.</tt><br>
<br>
<tt>After declaration of the variables, we actually check the dentry and</tt><br>
<tt>dentry-&gt;d_inode, and if they are not NULL, assign dentry-&gt;d_inode to inode</tt><br>
<tt>variable.</tt><br>
<br>
<tt>if (dentry == NULL || dentry-&gt;d_inode == NULL)</tt><br>
<tt>	return 0;</tt><br>
<tt>inode = dentry-&gt;d_inode;</tt><br>
<br>
<tt>&gt; <br>
&gt; <br>
&gt; &gt; <br>
&gt; &gt; Cc: Steve French &lt;smfltc@us.ibm.com&gt;<br>
&gt; &gt; Signed-off-by: Prasad V Potluri &lt;pvp@us.ibm.com&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; <br>
&gt; &gt; diff -uprN a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c<br>
&gt; &gt; --- a/fs/nfsd/nfs2acl.c 2007-10-09 15:31:38.000000000 -0500<br>
&gt; &gt; +++ b/fs/nfsd/nfs2acl.c 2007-10-24 14:03:13.000000000 -0500<br>
&gt; &gt; @@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; struct nfsd3_getaclres *resp)<br>
&gt; &gt; &nbsp;{<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; struct dentry *dentry = resp-&gt;fh.fh_dentry;<br>
&gt; &gt; - &nbsp; &nbsp; struct inode *inode = dentry-&gt;d_inode;<br>
&gt; &gt; + &nbsp; &nbsp; struct inode *inode;<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; struct kvec *head = rqstp-&gt;rq_res.head;<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; unsigned int base;<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; int n;<br>
&gt; &gt; --<br>
&gt; &gt; Thanks.<br>
&gt; &gt; <br>
&gt; &gt; Regards,<br>
&gt; &gt; Prasad Potluri<br>
&gt; &gt; email: pvp at-sign us dot ibm dot com<br>
&gt; &gt; -------------------------------------------------------------------------<br>
&gt; &gt; This SF.net email is sponsored by: Splunk Inc.<br>
&gt; &gt; Still grepping through log files to find problems? &nbsp;Stop.<br>
&gt; &gt; Now Search log events and configuration files using AJAX and a browser.<br>
&gt; &gt; Download your FREE copy of Splunk now &gt;&gt; <a href="http://get.splunk.com/">http://get.splunk.com/</a><br>
&gt; &gt; _______________________________________________<br>
&gt; &gt; NFS maillist &nbsp;- &nbsp;NFS@lists.sourceforge.net<br>
&gt; &gt; <a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br>
&gt; <br>
&gt; <br>
&gt; -------------------------------------------------------------------------<br>
&gt; This SF.net email is sponsored by: Splunk Inc.<br>
&gt; Still grepping through log files to find problems? &nbsp;Stop.<br>
&gt; Now Search log events and configuration files using AJAX and a browser.<br>
&gt; Download your FREE copy of Splunk now &gt;&gt; <a href="http://get.splunk.com/">http://get.splunk.com/</a><br>
&gt; _______________________________________________<br>
&gt; NFS maillist &nbsp;- &nbsp;NFS@lists.sourceforge.net<br>
&gt; <a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br>
Thanks.</tt><br>
<br>
<tt>Regards,</tt><br>
<tt>Prasad Potluri</tt><br>
<tt>email: pvp at-sign us dot ibm dot com</tt><br>
</body></html>
--0__=08BBF9ECDFC7FC228f9e8a93df938690918c08BBF9ECDFC7FC22--



--===============2025350691==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============2025350691==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2025350691==--
