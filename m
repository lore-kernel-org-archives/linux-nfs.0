From: Ming Zhang <blackmagic02881@gmail.com>
Subject: Re: question about fh_copy
Date: Mon, 29 Jan 2007 09:10:37 -0500
Message-ID: <1170079837.2871.15.camel@localhost.localdomain>
References: <1169911208.2767.15.camel@localhost.localdomain>
	<20070128230148.GB12125@fieldses.org>
	<1170030999.9144.8.camel@localhost.localdomain>
	<20070129010419.GF12125@fieldses.org>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBXDU-0008D4-Qc
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 06:10:40 -0800
Received: from an-out-0708.google.com ([209.85.132.243])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBXDU-0000RK-9Q
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 06:10:42 -0800
Received: by an-out-0708.google.com with SMTP id d40so1061155and
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 06:10:39 -0800 (PST)
In-Reply-To: <20070129010419.GF12125@fieldses.org>
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

On Sun, 2007-01-28 at 20:04 -0500, J. Bruce Fields wrote:
> On Sun, Jan 28, 2007 at 07:36:39PM -0500, Ming Zhang wrote:
> > On Sun, 2007-01-28 at 18:01 -0500, J. Bruce Fields wrote:
> > > On Sat, Jan 27, 2007 at 10:20:08AM -0500, Ming Zhang wrote:
> > > > A question about fh_copy(). This function is called many times on
> > > > argument passed directly from nfs clients. If a malicious nfs client
> > > > forge a fh, then fh_copy can invoke oops quite easily.
> > > 
> > > I don't see how; can you explain?
> > 
> > svc_process at http://lxr.linux.no/source/net/sunrpc/svc.c?v=2.6.18#L386
> > invoke a rpc processing function, for example, nfsd3_proc_getattr
> > then at http://lxr.linux.no/source/fs/nfsd/nfs3proc.c?v=2.6.18#L64
> > invoke fh_copy before fh_verify. since src coming from client, client
> > can forge a fh to let code
> > http://lxr.linux.no/source/include/linux/nfsd/nfsfh.h?v=2.6.18#L222 get
> > executed. if fh_dentry is a invalid pointer, it can get oops.
> 
> The fh_dentry field does not contain client-provided data; look at
> nfs3xdr.c:decode_fh() to see how the svc_fh structure is initialized.

my fault. in decode_fh, it only copy fh_handle. i read it too fast and
thought it copy the whole svc_fh.

sorry for the noise.



> 
> --b.
-- 
http://blackmagic02881.wordpress.com/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
