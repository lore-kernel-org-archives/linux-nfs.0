From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/5] rpc.mountd: Fix mountd buffer overflow when
 using large numbers of netgroups (resend)
Date: Fri, 28 Sep 2007 07:19:29 -0400
Message-ID: <20070928071929.c5b5632b.jlayton@redhat.com>
References: <200709271053.l8RArcOw031610@dantu.rdu.redhat.com>
	<18172.24167.3212.167596@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbDse-0004f8-Cu
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 04:19:36 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbDsf-0003SI-Uc
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 04:19:41 -0700
In-Reply-To: <18172.24167.3212.167596@notabene.brown>
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

On Fri, 28 Sep 2007 11:52:39 +1000
Neil Brown <neilb@suse.de> wrote:

> On Thursday September 27, jlayton@redhat.com wrote:
> > This patchset is intended to address the buffer overrun reported by
> > Stefan Walter when a client matches a large number of netgroups. The
> > main problem is that the string returned by client_compose can be any
> > length, and that is strcpy()'ed into a fixed-length array.
> > 
> > The first four patches are cleanup patches. They also take care of the
> > actual buffer overrun. The last patch implements Neil Brown's suggestion
> > to allow mountd to conditionally map ipaddr to ipaddr in the
> > auth.unix.ip cache and to only check mount requests against exports that
> > match the path.
> 
> All applied... however
> > 
> > Unlike earlier versions of this patch, there is no way to select this
> > mode manually. The reason is that explaining when an admin should select
> > this mode is difficult and adding an option would be very confusing. If
> > it becomes desirable to do so, however, we can always add one later.
> 
> I'm not convinced by this argument.  The difference between a bug and
> a feature is that a feature can be turned off (?)
> 
> "Different netgroup-based configurations benefit from different
>  tradeoffs in lookup and cache behaviour in mountd.
>  If some client hosts are in many different netgroups, and these
>  netgroups control access to a similar number of filesystems, then it
>  is best to check for membership of a client only in the netgroups
>  relating to filesystems that it is actually trying to access.
>  However if there are relatively few netgroups each with many member
>  hosts, it is best to find a complete list of all netgroups that a
>  given client is in as this make it easy to cache access tests.
> 
>  Mountd will normally attempt to guess the best caching and lookup
>  strategy based on a simple analysis of the /etc/exports file.  The
>  choice mountd makes can be force by using the --netgroups=many or
>  --netgroups=few command line options.
> "
> 
> Certainly it doesn't give the full story, but it means that the option
> is there in case the default breaks in some scenario that we haven't
> thought of yet.
> 
> Am I at all convincing?
> 

Yes. This is a really tough call, IMO. On the one hand, having things
"just work" is the ideal situation. On the other hand, giving people
the ability to affect this behavior could be important in some
situations. The hard part is that this is really an implementation
detail that users really shouldn't need to worry about.

I'll follow your lead on this. If you think an option is warranted here,
I can roll up a patch to add one...

Thanks,
--
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
