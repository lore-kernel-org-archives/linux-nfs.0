From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Problem with patch-C-NfsdRevalidate
Date: Thu, 14 Nov 2002 13:11:26 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15827.1614.91775.499397@notabene.cse.unsw.edu.au>
References: <006301c28b75$8f7e0370$47426682@itee.uq.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18C9Th-0004MW-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Nov 2002 18:11:33 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <c.pascoe@itee.uq.edu.au>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 14 Nov 2002 13:11:27 +1100
To: "Chris Pascoe" <c.pascoe@itee.uq.edu.au>
In-Reply-To: message from Chris Pascoe on Thursday November 14
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday November 14, c.pascoe@itee.uq.edu.au wrote:
> Hi Neil,
> 
> In
> http://cgi.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.20-rc1/patch-C-Nf
> sdRevalidate,
> fh_compose may never be called and err will be left set to a dentry's
> address or nfserr_acces (is that nfserr_acces ever used?) - if
> dentry->d_inode/dentry->d_inode->i_op/dentry->d_inode->i_op->revalidate is
> NULL.
> 
> Applying this patch results in problems with my Solaris clients, at least
> when trying to create a new file or when trying to stat a nonexistent file
> - output from truss:
> 
> open("/home/chrisp/a.lock.1036824940.2046.kauri", O_WRONLY|O_CREAT|O_EXCL,
> 0666) Err#-1057499168
> lstat("/home/chrisp/a.lock", 0xFFBECFB8)  Err#-1071055655
> 
> If I arrange the tests as below, to call fh_compose even if we can't call
> revalidate, all seems happy.  Is this behaviour correct?

Yes, you are correct.  The code was definately broken.
Having:
   if (x)
	if (Y)
		z;
   else
	w;

is always a bad idea !

Thanks a lot.
Your new code looks right.


NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: Are you worried about 
your web server security? Click here for a FREE Thawte 
Apache SSL Guide and answer your Apache SSL security 
needs: http://www.gothawte.com/rd523.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
