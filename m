From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Thu, 24 May 2007 00:39:03 +1000
Message-ID: <20070523143903.GM14076@sgi.com>
References: <20070523023206.GA14076@sgi.com>
	<C27939D4.30F92%tom@opengridcomputing.com>
	<20070523064157.GE14076@sgi.com> <46544377.4090604@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	NeilBrown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqrzb-0005dF-0y
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:39:11 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+AImMUo70fxPciQpXZA8fplp6ZeNjBOb8=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqrzd-00046R-RS
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:39:14 -0700
In-Reply-To: <46544377.4090604@oracle.com>
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

On Wed, May 23, 2007 at 09:36:55AM -0400, Chuck Lever wrote:
> Greg Banks wrote:
> >On Wed, May 23, 2007 at 12:22:44AM -0500, Tom Tucker wrote:
> >>
> >>
> >>On 5/22/07 9:32 PM, "Greg Banks" <gnb@sgi.com> wrote:
> >>
> >>>On Tue, May 22, 2007 at 12:34:23PM -0500, Tom Tucker wrote:
> >>I need to do a little clean up (e.g. atomic_inc()) and then I'll add them 
> >>as
> >>suggested. If there are dissenters, please speak now...
> >
> >You should be able to get away with just ++.  They're only stats,
> >it's not like you have logic depending on them being exact.
> 
> The usual way to do this is to allocate separate stat arrays for each 
> CPU.  All the per-CPU arrays are summed only when something wants to 
> display stat totals.
> 
> That way you can use ++, be fairly sure you will get accurate 
> statistics, and not have to be concerned about CPU cache effects or lock 
> contention.

Here in SGI, home of the multiple-thousand CPU Linux boxes, making
data structures per-cpu tends to be done...thoughtfully.

In any case, the remainder of svc_stat gets no such treatment today.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
