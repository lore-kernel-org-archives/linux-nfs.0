From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: nfs3/krb5 mounts fail
Date: Tue, 12 Dec 2006 21:17:43 -0500
Message-ID: <4d569c330612121817u715a0ad2g10b2f7a46a4a26fe@mail.gmail.com>
References: <20061211185547.GD25219@xerus.org>
	<4d569c330612120920g3d36cfe6j8baaf3054fec6ac3@mail.gmail.com>
	<20061212233813.GD21890@xerus.org>
	<4d569c330612121807x6a37db7av427cec506dd0b15b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuJgn-00086I-56
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 18:17:45 -0800
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuJgn-0002Oa-8t
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 18:17:46 -0800
Received: by nf-out-0910.google.com with SMTP id c31so531455nfb
	for <nfs@lists.sourceforge.net>; Tue, 12 Dec 2006 18:17:44 -0800 (PST)
To: "Christian G. Warden" <cwarden@xerus.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <4d569c330612121807x6a37db7av427cec506dd0b15b@mail.gmail.com>
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

On 12/12/06, Kevin Coffman <kwc@citi.umich.edu> wrote:
> On 12/12/06, Christian G. Warden <cwarden@xerus.org> wrote:
> > On Tue, Dec 12, 2006 at 12:20:33PM -0500, Kevin Coffman wrote:
> > > On 12/11/06, Christian G. Warden <cwarden@xerus.org> wrote:
> > > >I'm having a problem where nfs3 filesystems mounted with krb5 fail after
> > > >about 2 hours.  In userspace, I get a permission denied error when
> > > >trying to access such a filesystem.  Restarting rpc.svcgssd on the
> > > >server fixes the problem.
> > > >
> > > >Below is the debugging output from the client and server?  Does anything
> > > >indicate where the problem might be?
> > > >
> > > >Thanks,
> > > >Christian
> > >
> > > I'm not sure what is going on.  What kernel version is on the server?
> >
> > It's 2.6.17 (Debian kernel 2.6.17-2-xen-686) on the server and 2.6.18
> > (Debian kernel 2.6.18-3-xen-686) on the client.
> >
> > > The svcgssd messages indicate it is happy and sending down a context,
> > > but it appears that the kernel is dropping the request?
> > >
> > > >Dec 11 10:18:35 fs01 kernel: svc: got len=532
> > > >Dec 11 10:18:35 fs01 kernel: svc: svc_authenticate (6)
> > > >Dec 11 10:18:35 fs01 kernel: RPC:      svcauth_gss: argv->iov_len = 504
> > > >Dec 11 10:18:35 fs01 kernel: Want update, refage=120, age=0
> > > >Dec 11 10:18:35 fs01 kernel: svc: svc_process dropit
> > > >Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 dropped request
> > >
> > > Followed by:
> > >
> > > >Dec 11 10:18:35 fs01 kernel: RPC:      Succesfully imported new context.
> > >
> > > Could you send a network trace containing the conversation between
> > > client and server when this happens?
> >
> > The dump is attached.
> >
> > Thanks for your help.
> >
> > Christian
>
> Thanks for the trace.  So even though the userland code (svcgssd) says
> that it sent a context down to the kernel, the kernel code in
> gss_write_init_verf() is not finding it and returns GSS_S_NO_CONTEXT
> to the client.
>
> It seems like I've seen this before, but I don't recall the details
> right now.  I'll try to locate it...
>
> K.C.

I believe this looks exactly like the problem discussed here:
http://marc.theaimsgroup.com/?l=linux-nfs&m=116225377701186&w=2

I don't recall coming up with a solution.  The theory was possibly a
memory leak.

Bruce, could this be related to the leaks recently discovered and plugged?

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
