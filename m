From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix incorrect assignment
Date: Thu, 25 Oct 2007 12:03:19 -0400
Message-ID: <20071025160319.GA31888@fieldses.org>
References: <20071024205736.GL29830@fieldses.org>
	<OF5B1D195B.8B37E3EE-ON8725737F.00547AB2-8625737F.0054CCF1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs-bounces@lists.sourceforge.net, nfs@lists.sourceforge.net,
	smfltc@us.ibm.com
To: Prasad P <pvp@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <OF5B1D195B.8B37E3EE-ON8725737F.00547AB2-8625737F.0054CCF1@us.ibm.com>
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

On Thu, Oct 25, 2007 at 10:26:14AM -0500, Prasad P wrote:
> nfs-bounces@lists.sourceforge.net wrote on 10/24/2007 03:57:36 PM:
> 
> > On Wed, Oct 24, 2007 at 03:14:32PM -0500, Prasad P wrote:
> > >
> > >
> > > Dereferenced pointer "dentry" without checking and assigned to inode
> > > in the declaration.
> >
> > Seems reasonable, but: looking at nfsd_dispatch(), it appears that the
> > encode function is never called in this case (since rq_vers == 2 and
> > nfsacld_proc_getacl() would have returned an error if it couldn't find a
> > dentry).  Am I missing something?  Do you have a test case?
> >
> > --b.
> 
> No, I don't have a test case.  This error was found by coverity scan.
> 
> After declaration of the variables, we actually check the dentry and
> dentry->d_inode, and if they are not NULL, assign dentry->d_inode to inode
> variable.
> 
> if (dentry == NULL || dentry->d_inode == NULL)
>       return 0;
> inode = dentry->d_inode;

Yeah, the current code is obviously a little schizophrenic.  I'm just
wondering whether we should fix it by deleting the early assignment or
by removing the unnecessary checks.

--b.

> 
> >
> >
> > >
> > > Cc: Steve French <smfltc@us.ibm.com>
> > > Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
> > > ---
> > >
> > > diff -uprN a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> > > --- a/fs/nfsd/nfs2acl.c 2007-10-09 15:31:38.000000000 -0500
> > > +++ b/fs/nfsd/nfs2acl.c 2007-10-24 14:03:13.000000000 -0500
> > > @@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st
> > >             struct nfsd3_getaclres *resp)
> > >  {
> > >       struct dentry *dentry = resp->fh.fh_dentry;
> > > -     struct inode *inode = dentry->d_inode;
> > > +     struct inode *inode;
> > >       struct kvec *head = rqstp->rq_res.head;
> > >       unsigned int base;
> > >       int n;
> > > --
> > > Thanks.
> > >
> > > Regards,
> > > Prasad Potluri
> > > email: pvp at-sign us dot ibm dot com
> > >
> -------------------------------------------------------------------------
> > > This SF.net email is sponsored by: Splunk Inc.
> > > Still grepping through log files to find problems?  Stop.
> > > Now Search log events and configuration files using AJAX and a browser.
> > > Download your FREE copy of Splunk now >> http://get.splunk.com/
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
> > -------------------------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc.
> > Still grepping through log files to find problems?  Stop.
> > Now Search log events and configuration files using AJAX and a browser.
> > Download your FREE copy of Splunk now >> http://get.splunk.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> Thanks.
> 
> Regards,
> Prasad Potluri
> email: pvp at-sign us dot ibm dot com
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
