From: Neil Brown <neilb@suse.de>
Subject: Re: Bug#443591: nfs-kernel-server: Unexporting directories no
	longer working
Date: Mon, 15 Oct 2007 10:02:01 +1000
Message-ID: <18194.44537.928610.815227@notabene.brown>
References: <20070922174231.11200.29119.reportbug@localhost.localdomain>
	<20070923000102.GA29785@uio.no>
	<18167.24613.796605.199161@notabene.brown>
	<46F8483E.3000103@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: 443591@bugs.debian.org, nfs@lists.sourceforge.net
To: David Liontooth <liontooth@cogweb.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhDPL-0007tm-LR
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 17:02:08 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IhDPQ-0007vg-7U
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 17:02:13 -0700
In-Reply-To: message from David Liontooth on Monday September 24
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

On Monday September 24, liontooth@cogweb.net wrote:
> 
> Hi Neil,
> 
> Thanks for looking.
> 
> Neil Brown wrote:
> > On Sunday September 23, sgunderson@bigfoot.com wrote:
> >   
> >> On Sat, Sep 22, 2007 at 10:42:31AM -0700, David Liontooth wrote:
> >>     
> >>> Package: nfs-kernel-server
> >>> Version: 1:1.1.0-13
> >>> Severity: normal
> >>>
> >>>
> >>> The command to unexport a directory appears to no longer have any effect.
> >>>
> >>> I issue "exportfs -u :/tv01" and "exportfs" shows /tv01 still exported; consequently, I cannot unmount it.
> >>> In contrast, removing /tv01 from /etc/exports and then running exportfs -ra successfully removes the export.
> >>>
> >>> This used to work fine.
> >>>       
> >> Sending this on to upstream, as I cannot see any good reason offhand why it
> >> should not work.
> >>     
> >
> > Some simple testing and code review suggests that this works as
> > expected.  However it is possible that I am expecting something
> > different to you, or testing something different.
> >
> > You say you:
> >     exportfs -u :/tv01
> >
> > What exactly is in your /etc/exports that this is expected to revert?
> >   
> 
> /tv01 \
>         134.32.443.30(ro,no_subtree_check,async) \
>         134.32.443.32(ro,no_subtree_check,async) \
>         134.32.443.33(ro,no_subtree_check,async) \
>         134.32.443.34(ro,no_subtree_check,async) \
>         134.32.443.35(ro,no_subtree_check,async) \
>         134.32.443.36(ro,no_subtree_check,async) \
>         134.32.443.37(ro,no_subtree_check,async)

To unexport /tv01, you would need to individually unexport each of
those export.  Or edit /etc/exports to remove those lines and
   exportfs -r

> 
> Several other drives have similar entries.
> > The obvious answer would be
> >
> >     /tv01  (some,flags,here)
> >
> > however "exportfs" will complain about that, so I suspect not.
> >
> > Maybe you have:
> >
> >     /tv01 somehost(someflags)  otherhost(otherflags)
> >
> > and you expect
> >     exportfs -u :/tv01
> >
> > to unexport /tv01 to all hosts?  I would agree that doesn't work.  Did
> > it ever?  What version?
> >   
> 
> I see. So that would unexport only the first one?

No, it would not export anything as that is asking to stop exporting
it to the wildcard host (matches anything) and it is not currently
exported to the wildcard host.

> 
> Can I unexport only /tv01 to all hosts?
> (If it's just a matter of my being uninformed, let's close the bug --
> but I'd appreciate an answer!)

No.  You cannot currently export a filesystem.  You can only unexport
an 'export' which is a host:filesystem combination.

> 
> > As an aside, you can always:
> >    exportfs -f
> > and then unmount filesystems.  They will be free to be unmounted until
> > the next NFS access request arrives.  Maybe that will serve your
> > needs?
> >   
> I see -- that may be helpful -- but what if someone is accessing one of
> the drives right then?

If you 
  exportfs -f ; umount /tv01
there is a chance that a request will arrive between the two, so the
umount will fail.
You could instead
   umount -l /tv01 ; exportfs -f

which will avoid the race and be just as effective.


> I would prefer to have individual control; I export a dozen other drives
> to several different machines, and they should not be unexported.

"exportfs -f" will not exactly unexport them.  It just removes cached
information from the kernel so that it has to ask mountd again.
So the most you will notice is a slight pause, and you probably won't
notice that unless the system is very busy and there are lots of
mounts - or hostname/netgroup lookup is very slow.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
