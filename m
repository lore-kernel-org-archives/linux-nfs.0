From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd stops functioning
Date: Fri, 27 Aug 2004 19:16:54 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040827231654.GA2836@fieldses.org>
References: <411217BE.8070209@framestore-cfc.com> <20040805144659.GD25948@fieldses.org> <16686.43784.910598.870375@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0pxt-00088G-Cb
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 16:17:01 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0pxq-0007QK-HP
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 16:17:01 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16686.43784.910598.870375@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, Aug 27, 2004 at 01:31:20PM +1000, Neil Brown wrote:
> I don't think this patch is needed (though it wouldn't actually break anything).
> The loop in svc_run.c starts:
> 
> 
> 		readfds = svc_fdset;
> 		cache_set_fds(&readfds);
> 
> so readfds is completely initialised at the top of the loop, so
> clearing something at the bottom (which is essentially what this patch
> does) should be a no-op.
> 
> Am I wrong?

Note that cache_process_req() (which the patch below modifies) is not
all the way at the bottom of the loop; there's still an importan call to
svc_getreqset() after it.

If I understand the problem correctly, what happens is that if select()
returns with a set that includes two file descriptors, the first for a
cache channel and the second for an rpc socket, and if we don't clear
the first file descriptor from that set before passing it to
svc_getreqset(), then the rpc code will try to read an rpc request from
a cache channel file, and will get very confused.

The symptom is that mountd may die occasionally on a server that's
using the new interface (hence mountd is handling upcalls), and that's
getting a lot of mount requests.

I've never seen the bug myself, because I'm almost always using nfsv4,
hence only use mountd to handle upcalls....

--b.


> > >From Garrick Staples <garrick@usc.edu>:
> > 
> > After mountd handles a cache upcall, we should clear the relevant bits in the
> > fd_set.
> > 
> > ---
> > 
> >  nfs-utils-1.0.6-bfields/utils/mountd/cache.c |    1 +
> >  1 files changed, 1 insertion(+)
> > 
> > diff -puN utils/mountd/cache.c~cache_select_bugfix utils/mountd/cache.c
> > --- nfs-utils-1.0.6/utils/mountd/cache.c~cache_select_bugfix	2004-07-14 12:52:57.000000000 -0400
> > +++ nfs-utils-1.0.6-bfields/utils/mountd/cache.c	2004-07-14 12:52:57.000000000 -0400
> > @@ -315,6 +315,7 @@ int cache_process_req(fd_set *readfds) 
> >  		    FD_ISSET(fileno(cachelist[i].f), readfds)) {
> >  			cnt++;
> >  			cachelist[i].cache_handle(cachelist[i].f);
> > +			FD_CLR(fileno(cachelist[i].f), readfds);
> >  		}
> >  	}
> >  	return cnt;
> > _
> > 
> > 
> > -------------------------------------------------------
> > This SF.Net email is sponsored by OSTG. Have you noticed the changes on
> > Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
> > one more big change to announce. We are now OSTG- Open Source Technology
> > Group. Come see the changes on the new OSTG site. www.ostg.com
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
