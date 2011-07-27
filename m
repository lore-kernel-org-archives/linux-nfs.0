Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab1G0DN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jul 2011 23:13:26 -0400
Subject: Re: [Libtirpc-devel] [PATCH] Autofs configure fails to detect IPv6
 when libtirpc is enabled
From: Ian Kent <ikent@redhat.com>
To: Chuck Lever <chucklever@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        autofs mailing list <autofs@linux.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
In-Reply-To: <1311734445.3473.19.camel@perseus.themaw.net>
References: <1311683346-16881-1-git-send-email-steved@redhat.com>
	 <8A84CF7D-9579-4645-AE5D-FE8358F466C0@gmail.com>
	 <4E2F2DE6.5030500@RedHat.com>  <1311728231.3473.7.camel@perseus.themaw.net>
	 <1311729784.3473.14.camel@perseus.themaw.net>
	 <A8F3853A-9C75-4F65-8EEB-88DD13C3FF9B@gmail.com>
	 <1311734445.3473.19.camel@perseus.themaw.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Jul 2011 11:13:12 +0800
Message-ID: <1311736392.3473.22.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 10:40 +0800, Ian Kent wrote:
> On Tue, 2011-07-26 at 22:09 -0400, Chuck Lever wrote:
> > On Jul 26, 2011, at 9:23 PM, Ian Kent wrote:
> > 
> > > On Wed, 2011-07-27 at 08:57 +0800, Ian Kent wrote:
> > >> On Tue, 2011-07-26 at 17:13 -0400, Steve Dickson wrote:
> > >>> 
> > >>> On 07/26/2011 10:50 AM, Chuck Lever wrote:
> > >>>> 
> > >>>> On Jul 26, 2011, at 2:29 PM, Steve Dickson wrote:
> > >>>> 
> > >>>>> From: Ian Kent <raven@themaw.net>
> > >>>>> 
> > >>>>> The IPv6 client functions clntudp6_bufcreate(), clntudp6_create and
> > >>>>> clnttcp6_create and the server functions svcudp6_bufcreate(),
> > >>>>> svctcp6_create() and svcudp6_create() are not included in the library
> > >>>>> whe libtirpc is built.
> > >>>> 
> > >>>> Are these part of the libtirpc standard API?  I'm not sure why we would need them if, say, Solaris does not support these.
> > >>> It appears they are not since they are not mentioned the man pages.....
> > >>> But, at least in the autofs code, they are expected
> > >>>   https://bugzilla.redhat.com/show_bug.cgi?id=711956#c0
> > >>> 
> > >>> Ian, where else are these routines defined? 
> > >> 
> > >> Now that I look I can't find the original source tar that was used for
> > >> libtirpc, thought I had it.
> > > 
> > > Found what I had.
> > > 
> > > AFAICT what I think was the original source doesn't have any IPv6 code
> > > that I can see.
> > > 
> > > Worse, these functions were excluded with the "#ifdef INET6_NOT_USED"
> > > macro as far back as libtirpc version 0.1.5 so, my bad, sorry.
> > > 
> > >> 
> > >> The story is that long ago when I changed autofs to use libtirpc (to
> > >> make it ready for IPv6) I found these functions in the source and they
> > >> were (obviously) the IPv6 counterparts for the corresponding IPv4
> > >> functions which I was already using, so I used them. It took me quite a
> > >> while to realize my code wasn't working and then I found that somewhere
> > >> along the line they have been excluded, oops!
> > >> 
> > >> If there are to be no IPv6 counterparts for the corresponding IPv4
> > >> functions which functions should I use then?
> > > 
> > > So what can I use?
> > > 
> > > It seems to me that these functions would be useful for people porting
> > > code that uses the corresponding IPv4 functions so could we define them
> > > please. At some point someone must have had that same idea ....
> > 
> > It looks to me like these functions were part of an original attempt
> > at IPv6 support that was abandoned long ago.  They are not part of
> > TI-RPC, but as you observed, they are merely IPv6 versions of the
> > legacy RPC API. I don't see these implemented in glibc, for example.
> > 
> > For IPv6 support, use functions that are part of the modern libtirpc
> > API.  This is described in Sun doc 816-1435.  You probably will be
> > most successful with the "simplified interface" which is described in
> > Chapter 4. You might need somewhat more extensive surgery since I'm
> > guessing you have separate code paths to invoke the IPv4 and IPv6
> > legacy RPC functions; generally speaking that should not be needed
> > when using the libtirpc API.
> 
> I doubt the simplified interface will be adequate since this code was
> written because of a need for greater control over timeouts. Perhaps
> that won't be the case, I don't know yet.
> 
> Your suggestion amounts to saying I need to re-write all my RPC code.

That comment is a bit dramatic, sorry.

Actually I should be able to replace these calls with the contents of
the functions as they are in libtirpc without too much trouble.

> 
> > 
> > 
> > 
> > > 
> > >> 
> > >>> 
> > >>> steved
> > >>> 
> > >>>> 
> > >>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
> > >>>>> ---
> > >>>>> src/rpc_soc.c |    4 ++--
> > >>>>> 1 files changed, 2 insertions(+), 2 deletions(-)
> > >>>>> 
> > >>>>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
> > >>>>> index c678429..584ac71 100644
> > >>>>> --- a/src/rpc_soc.c
> > >>>>> +++ b/src/rpc_soc.c
> > >>>>> @@ -236,7 +236,7 @@ clnttcp_create(raddr, prog, vers, sockp, sendsz, recvsz)
> > >>>>> 
> > >>>>> /* IPv6 version of clnt*_*create */
> > >>>>> 
> > >>>>> -#ifdef INET6_NOT_USED
> > >>>>> +#ifdef INET6
> > >>>>> 
> > >>>>> CLIENT *
> > >>>>> clntudp6_bufcreate(raddr, prog, vers, wait, sockp, sendsz, recvsz)
> > >>>>> @@ -392,7 +392,7 @@ svcraw_create()
> > >>>>> 
> > >>>>> 
> > >>>>> /* IPV6 version */
> > >>>>> -#ifdef INET6_NOT_USED
> > >>>>> +#ifdef INET6
> > >>>>> SVCXPRT *
> > >>>>> svcudp6_bufcreate(fd, sendsz, recvsz)
> > >>>>> 	int fd;
> > >>>>> -- 
> > >>>>> 1.7.6
> > >>>>> 
> > >>>>> 
> > >>>>> ------------------------------------------------------------------------------
> > >>>>> Magic Quadrant for Content-Aware Data Loss Prevention
> > >>>>> Research study explores the data loss prevention market. Includes in-depth
> > >>>>> analysis on the changes within the DLP market, and the criteria used to
> > >>>>> evaluate the strengths and weaknesses of these DLP solutions.
> > >>>>> http://www.accelacomm.com/jaw/sfnl/114/51385063/
> > >>>>> _______________________________________________
> > >>>>> Libtirpc-devel mailing list
> > >>>>> Libtirpc-devel@lists.sourceforge.net
> > >>>>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
> > >>>> 
> > >>> 
> > >>> ------------------------------------------------------------------------------
> > >>> Got Input?   Slashdot Needs You.
> > >>> Take our quick survey online.  Come on, we don't ask for help often.
> > >>> Plus, you'll get a chance to win $100 to spend on ThinkGeek.
> > >>> http://p.sf.net/sfu/slashdot-survey
> > >>> _______________________________________________
> > >>> Libtirpc-devel mailing list
> > >>> Libtirpc-devel@lists.sourceforge.net
> > >>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
> > >> 
> > > 
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 


