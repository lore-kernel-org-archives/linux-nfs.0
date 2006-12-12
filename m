From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: nfs3/krb5 mounts fail
Date: Tue, 12 Dec 2006 12:20:33 -0500
Message-ID: <4d569c330612120920g3d36cfe6j8baaf3054fec6ac3@mail.gmail.com>
References: <20061211185547.GD25219@xerus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuBIy-0001v8-Gw
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 09:20:36 -0800
Received: from an-out-0708.google.com ([209.85.132.240])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuBIw-0004yi-U3
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 09:20:37 -0800
Received: by an-out-0708.google.com with SMTP id d40so770260and
	for <nfs@lists.sourceforge.net>; Tue, 12 Dec 2006 09:20:34 -0800 (PST)
To: "Christian G. Warden" <cwarden@xerus.org>
In-Reply-To: <20061211185547.GD25219@xerus.org>
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

On 12/11/06, Christian G. Warden <cwarden@xerus.org> wrote:
> I'm having a problem where nfs3 filesystems mounted with krb5 fail after
> about 2 hours.  In userspace, I get a permission denied error when
> trying to access such a filesystem.  Restarting rpc.svcgssd on the
> server fixes the problem.
>
> Below is the debugging output from the client and server?  Does anything
> indicate where the problem might be?
>
> Thanks,
> Christian

I'm not sure what is going on.  What kernel version is on the server?

The svcgssd messages indicate it is happy and sending down a context,
but it appears that the kernel is dropping the request?

> Dec 11 10:18:35 fs01 kernel: svc: got len=532
> Dec 11 10:18:35 fs01 kernel: svc: svc_authenticate (6)
> Dec 11 10:18:35 fs01 kernel: RPC:      svcauth_gss: argv->iov_len = 504
> Dec 11 10:18:35 fs01 kernel: Want update, refage=120, age=0
> Dec 11 10:18:35 fs01 kernel: svc: svc_process dropit
> Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 dropped request

Followed by:

> Dec 11 10:18:35 fs01 kernel: RPC:      Succesfully imported new context.

Could you send a network trace containing the conversation between
client and server when this happens?

Thanks,
K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
