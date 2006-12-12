From: "Christian G. Warden" <cwarden@xerus.org>
Subject: Re: nfs3/krb5 mounts fail
Date: Tue, 12 Dec 2006 15:38:13 -0800
Message-ID: <20061212233813.GD21890@xerus.org>
References: <20061211185547.GD25219@xerus.org>
	<4d569c330612120920g3d36cfe6j8baaf3054fec6ac3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuHCd-0000Nc-It
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:38:27 -0800
Received: from sage.xerus.org ([64.74.153.194] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuHCd-0007Hu-JJ
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:38:29 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330612120920g3d36cfe6j8baaf3054fec6ac3@mail.gmail.com>
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


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 12, 2006 at 12:20:33PM -0500, Kevin Coffman wrote:
> On 12/11/06, Christian G. Warden <cwarden@xerus.org> wrote:
> >I'm having a problem where nfs3 filesystems mounted with krb5 fail after
> >about 2 hours.  In userspace, I get a permission denied error when
> >trying to access such a filesystem.  Restarting rpc.svcgssd on the
> >server fixes the problem.
> >
> >Below is the debugging output from the client and server?  Does anything
> >indicate where the problem might be?
> >
> >Thanks,
> >Christian
> 
> I'm not sure what is going on.  What kernel version is on the server?

It's 2.6.17 (Debian kernel 2.6.17-2-xen-686) on the server and 2.6.18
(Debian kernel 2.6.18-3-xen-686) on the client.
 
> The svcgssd messages indicate it is happy and sending down a context,
> but it appears that the kernel is dropping the request?
> 
> >Dec 11 10:18:35 fs01 kernel: svc: got len=532
> >Dec 11 10:18:35 fs01 kernel: svc: svc_authenticate (6)
> >Dec 11 10:18:35 fs01 kernel: RPC:      svcauth_gss: argv->iov_len = 504
> >Dec 11 10:18:35 fs01 kernel: Want update, refage=120, age=0
> >Dec 11 10:18:35 fs01 kernel: svc: svc_process dropit
> >Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 dropped request
> 
> Followed by:
> 
> >Dec 11 10:18:35 fs01 kernel: RPC:      Succesfully imported new context.
> 
> Could you send a network trace containing the conversation between
> client and server when this happens?

The dump is attached.

Thanks for your help.

Christian

--a8Wt8u1KmwUX3Y2C
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="dump.out"
Content-Transfer-Encoding: base64

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
d7gFSnCZ

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--a8Wt8u1KmwUX3Y2C--
