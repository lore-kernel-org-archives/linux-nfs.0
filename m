From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Mon, 24 Jul 2006 16:02:18 +1000
Message-ID: <17604.25194.644981.685495@cse.unsw.edu.au>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
	<44AE41D8.5040302@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G4tX4-0001Mn-VN
	for nfs@lists.sourceforge.net; Sun, 23 Jul 2006 23:03:11 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G4tX3-0006Wg-MX
	for nfs@lists.sourceforge.net; Sun, 23 Jul 2006 23:03:11 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Friday July 7
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

On Friday July 7, SteveD@redhat.com wrote:
> Hey Neil,
> 
> Neil Brown wrote:
> > Hi,
> >  I'd like to put out nfs-utils-1.0.9 by the end of the week.
> > There is (or will soon be) a -pre1 in
> >   http://www.kernel.org/pub/linux/utils/nfs/
> > and
> >   git://linux-nfs.org/nfs-utils
> > 
> > Recent changes can been seen at
> >    http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=log
> >   
> > If anyone cares to do some testing that would be great.
> 
> Well using the nfs-utils-1.0.9-pre1 tarball from kernel.org
> and the recent kernel patch set you posted here is what I found.
> 
> Starting and stopping nfsds did not kill neither the
> TCP or UDP connections. There were two problems with this.
> One, rpc.nfsd was incorrectly increasing nfsd_serv->sv_nrthreads
> in nfsd_svc() by calling nfsd_create_serv(); (Note: another side effect
> of this problem was only 7 nfsd process were start instead of 8)
> So the solution I've come up with is to only  have nfsd_create_serv()
> called when it needs to... basically:
>      if (nfsd_serv == NULL) {
>          error = nfsd_create_serv();
>          if (error)
>              goto out;
>      }

Hmm.. There is room for confusion here as sv_nrthreads is used as a
general reference count, rather than just a count of the number of
threads.
This is why e.g. we do
	nrservs -= (nfsd_serv->sv_nrthreads-1);
to find out how much to change the number of threads by.  The '-1' is
because we are currently holding a non-thread reference.

I think the real problem was that nfsd_create_serv was doing
	nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE,
			       nfsd_last_thread);
	if (nfsd_serv == NULL)
		err = -ENOMEM;
	else
		nfsd_serv->sv_nrthreads++;

and as svc_create sets sv_nrthreads to 1, it end up as '2', even
though there is only one reference.
But I'll be sure to test this before submitting it.

> 
> The second problem was an oops that occurred when the sv_nrthreads was
> incremented correctly... and Neil your going to love this one... ;-)
> 
> In svc_delete_socket(), sock_release() was being called with a
> socket that was already closed... The socket was closed by the
> previous sockfd_put() when svsk->sk_sock->file != NULL... So
> the code changed from
>      if (svsk->sk_sock->file)
>          sockfd_put(svsk->sk_sock);
>      sock_release(svsk->sk_sock);
> to
>      if (svsk->sk_sock->file)
>          sockfd_put(svsk->sk_sock);
>      else
>          sock_release(svsk->sk_sock);
> 
> The reason Neil is going to love this is I asked him to
> make this change because in my previous testing, the only
> way I could get the connections to come down was to
> always call sock_release() even after the fput() of the
> file pointer... So it appears in Neil's rewrite, fput()
> is actually doing the release which is how it should work...

Yes.. I had a feeling I had missed up bit in fixing that all up once I
had figured out how it was meant to work.  Thanks for catching it.


> 
> Once I got the connections to come up and down as expected, I
> noticed I could not turn off any versions...
> 
> In the patches I sent Neil, I had to reverse the order of when
> nfssvc_setfds() and nfssvc_versbits() were called in rpc.nfsd.
> But in Neil's patch it appears nfssvc_versbits() is expect
> to be called before nfssvc_setfds(). After I switching the
> order of those calls... things started to work as expected..

Looks like I got that right in the released nfs-utils-1.0.9 - good.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
