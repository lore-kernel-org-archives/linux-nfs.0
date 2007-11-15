From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Thu, 15 Nov 2007 17:00:36 +0100
Message-ID: <20071115160036.GA18544@janus>
References: <473B3D0B.3060204@oracle.com>
	<1195065798.7584.37.camel@heimdal.trondhjem.org>
	<473B45C9.4060708@oracle.com>
	<1195069262.7584.54.camel@heimdal.trondhjem.org>
	<473B5278.7090408@oracle.com>
	<18235.41907.383911.722103@notabene.brown>
	<473C4FE2.1090402@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ish8y-0002JJ-SQ
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 08:00:40 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ish92-0002wW-8y
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 08:00:46 -0800
In-Reply-To: <473C4FE2.1090402@oracle.com>
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

On Thu, Nov 15, 2007 at 08:55:46AM -0500, Chuck Lever wrote:
> Neil Brown wrote:
> >On Wednesday November 14, chuck.lever@oracle.com wrote:
> >>Trond Myklebust wrote:
> >>>On Wed, 2007-11-14 at 14:00 -0500, Chuck Lever wrote:
> >>>>That's correct.  I'm just trying to understand why, historically, 
> >>>>rq_daddr was just the 32-bit address and not a full sockaddr to begin 
> >>>>with.  There may be something we're missing, like "we didn't want to 
> >>>>add another large field to this structure due to memory alignment or 
> >>>>allocation efficiency concerns".  :-)
> >>>Actually, rq_daddr by definition pretty much has to be of the same
> >>>address family as rq_addr, since they are the two endpoints for the same
> >>>socket. 
> >>>
> >>>However I can't see where rq_addr is being initialised for UDP sockets.
> >>>That is sort of worrying given that it is used among other things by the
> >>>nfsd duplicate reply cache...
> >>That's the other half of my question.  Why isn't nlmsvc_lookup_host 
> >>using rq_addr (without the d)?
> >
> >Git is your friend.
> >
> >commit c98451bdb2f3e6d6cc1e03adad641e9497512b49
> >Author: Frank van Maarseveen <frankvm@frankvm.com>
> >Date:   Mon Jul 9 22:25:29 2007 +0200
> >
> >    NLM: fix source address of callback to client
> >    
> >    Use the destination address of the original NLM request as the
> >    source address in callbacks to the client.
> >    
> >    Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
> >    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Silly me.  I had assumed that it had always been that way, and thus git 
> would not be helpful (git's history truncates at 2.6.12).
> 
> Unfortunately Frank's patch description doesn't explain *why* this 
> change was made.  I assume this fixes a bug with multi-homed servers?

Almost: Multiple NICs are probably not a problem (kernel should fill in
correct src address depending on outgoing interface) but for multiple
IP addresses on the same interface it definately is a problem.

When NFS clients A and B are contending for a lock the server needs
to do a callback to client B when the lock is released by client
A. Without above fix the kernel would pick an arbitrary source address
for callbacks. And (at least) the linux NFS client verifies the source
address of an NLM callback, see nlmclnt_grant().

IP aliases are very useful for virtualizing NFS servers (we run about
70 of them on 4 physical machines).

> What do you think of changing the rq_daddr field to be a sockaddr_storage?

One thing which still worries me is the sockaddr_storage size: this thing
is a bit large due to AF_UNIX support. AF_UNIX isn't used for NFS AFAIK.
Anyway, changing that is a separate issue.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
