From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Wed, 3 Dec 2008 12:25:18 -0500
Message-ID: <20081203172518.GD16846@fieldses.org>
References: <200811281541.39272.t.bubeck@reinform.de> <200811281705.45087.t.bubeck@reinform.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51292 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357AbYLCRZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2008 12:25:20 -0500
In-Reply-To: <200811281705.45087.t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 28, 2008 at 05:05:44PM +0100, Dr. Tilmann Bubeck wrote:
> To be more precise: the order between "exportfs -r" and "modprobe nfsd" is 
> important (and not "exportfs -r" and "rpc.mountd").

So, I'm confused: what are the before-and-after orders of all three
(modprobe, exportfs, and rpc.mountd)?

> 
> Am Freitag, 28. November 2008 15:41:38 schrieb Dr. Tilmann Bubeck:
> > According to manual page "exportfs -r" has two modes: legacy and new.
> > Fedora 10 seems to use the new mode and mounts /proc/fs/nfsd.
> >
> > But they use the following order in /etc/init.d/nfs:
> >   exportfs -r
> >   rpc.mountd
> >
> > This results in /proc/fs/nfsd/exports having all obsolete entries
> > from /var/lib/nfs/rmtab which causes a lot of trouble with stale NFS file
> > handles.

What problems exactly?

> > This seems to be wrong according to "man exportfs" in new mode.
> >
> > If I change the order to
> >   rpc.mountd
> >   exportfs -r
> >
> > then everything is OK and /proc/fs/nfsd/exports only contains the info
> > from /etc/exports and not all stale clients. This seems to be correct
> > according to "man exportfs" in new mode.
> >
> > Questions: is this behaviour a bug or at least bad? Shouldn't exportfs
> > being changed, so that when it detects "new" mode it will never feed rmtab
> > into the kernel and rely upon rpc.mountd answering the kernels questions as
> > stated in "man exportfs"?

That does sound wrong.

Perhaps rmtab should also be cleared on exportfs -r?  I don't really
understand how rmtab should work.

--b.

> >
> > If yes, then the order or the programs is irrelevant.
> > If not, should the order of the programs be reversed in Fedora?
> >
> > Thanks
> >  Till
> 
> 
> 
> -- 
> +-------+-------------------------------------------------------------+
> |       | dr. tilmann bubeck               reinform medien- und       |
> |       |                                  informationstechnologie AG |
> | rein  | fon  : +49 (711) 7 82 76-52      loeffelstr. 40             |
> | form  | fax  : +49 (711) 7 82 76-46      70597 stuttgart / germany  |
> |    AG | cell.: +49 (172) 8 84 29 72      fon: +49 (711) 75 86 56-10 |
> |       | email: t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org      http://www.reinform.de     |
> |       +-------------------------------------------------------------+
> |       | pflichtangaben nach paragraph 80, AktG:                     |
> |       | reinform medien- und informationstechnologie AG, stuttgart  |
> |       | handelsregister stuttgart, HRB 23001                        |
> |       | vorstand:     dr. tilmann bubeck (vorsitz), dr. tommy kuhn  |
> |       | aufsichtsrat: frank stege (vorsitz)                         |
> +-------+-------------------------------------------------------------+
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
