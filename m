From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/5] rpc.mountd: Fix mountd buffer overflow when
	using large numbers of netgroups (resend)
Date: Fri, 28 Sep 2007 11:52:39 +1000
Message-ID: <18172.24167.3212.167596@notabene.brown>
References: <200709271053.l8RArcOw031610@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib523-0000Jm-IE
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 18:52:43 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib528-0008J2-5e
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 18:52:48 -0700
In-Reply-To: message from Jeff Layton on Thursday September 27
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

On Thursday September 27, jlayton@redhat.com wrote:
> This patchset is intended to address the buffer overrun reported by
> Stefan Walter when a client matches a large number of netgroups. The
> main problem is that the string returned by client_compose can be any
> length, and that is strcpy()'ed into a fixed-length array.
> 
> The first four patches are cleanup patches. They also take care of the
> actual buffer overrun. The last patch implements Neil Brown's suggestion
> to allow mountd to conditionally map ipaddr to ipaddr in the
> auth.unix.ip cache and to only check mount requests against exports that
> match the path.

All applied... however
> 
> Unlike earlier versions of this patch, there is no way to select this
> mode manually. The reason is that explaining when an admin should select
> this mode is difficult and adding an option would be very confusing. If
> it becomes desirable to do so, however, we can always add one later.

I'm not convinced by this argument.  The difference between a bug and
a feature is that a feature can be turned off (?)

"Different netgroup-based configurations benefit from different
 tradeoffs in lookup and cache behaviour in mountd.
 If some client hosts are in many different netgroups, and these
 netgroups control access to a similar number of filesystems, then it
 is best to check for membership of a client only in the netgroups
 relating to filesystems that it is actually trying to access.
 However if there are relatively few netgroups each with many member
 hosts, it is best to find a complete list of all netgroups that a
 given client is in as this make it easy to cache access tests.

 Mountd will normally attempt to guess the best caching and lookup
 strategy based on a simple analysis of the /etc/exports file.  The
 choice mountd makes can be force by using the --netgroups=many or
 --netgroups=few command line options.
"

Certainly it doesn't give the full story, but it means that the option
is there in case the default breaks in some scenario that we haven't
thought of yet.

Am I at all convincing?

NeilBrown


> 
> Neil, I think this patchset is ready whenever you are...
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Acked-by: Steve Dickson <steved@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
