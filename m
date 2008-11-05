From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: gssapi and nfs4
Date: Wed, 5 Nov 2008 14:02:35 -0500
Message-ID: <20081105190235.GA969@fieldses.org>
References: <1225813410.2247.279.camel@brian-laptop> <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com> <1225824797.2247.345.camel@brian-laptop> <20081104224817.GB16121@fieldses.org> <1225862729.13506.8.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58563 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbYKETCh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 14:02:37 -0500
In-Reply-To: <1225862729.13506.8.camel-lA68w17JHpfIgqYUaR6mlLDks+cytr/Z@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 12:25:29AM -0500, Brian J. Murrell wrote:
> On Tue, 2008-11-04 at 17:48 -0500, J. Bruce Fields wrote: 
> > 
> > You can still vary ro/rw based on machine or security flavor; e.g.
> > 
> > 	/home	foo(sec=krb5,ro)
> > 	/home	bar(sec=krb5,rw)
> 
> Excellent.
> 
> > or
> > 
> > 	/home	foo(ro,sec=krb5,rw)
> > 
> > (readable by all users, writeable only by krb5 users).
> 
> Ahhh.  Very interesting.
> 
> > This should all
> > be documented by "man exports".
> 
> Yes, it appears to be.  My use of gss/krb5(...) was from some "howto"s
> that I found on the web.  Seems they are tad dated.
> 
> 
> > > I did notice the bit of text about the single pseudo filesystem.  Given
> > > that on my server, I exported a number of filesystems, including / to
> > > privileged (I'm in a very small and trusted environment) clients, it
> > > seemed natural to just set / to fsid 0.  I also exported the few other
> > > exports I wanted some nfs4 clients to mount as such:
> > > 
> > > /               gss/krb5i(rw,insecure,sync,wdelay,no_subtree_check,no_root_squash,fsid=0,crossmnt,anonuid=65534,anongid=65534)
> > > /home           gss/krb5i(rw,no_root_squash,sync,subtree_check,anonuid=65534,anongid=65534)
> > > /mnt/data       gss/krb5i(rw,sync,subtree_check,crossmnt,anonuid=65534,anongid=65534)
> > > /mnt/data/photos gss/krb5i(rw,sync,subtree_check,anonuid=65534,anongid=65534)
> > > 
> > > where those are all on different filesystems on the server.  I'm
> > > starting to feel like this is not how it's supposed to be done.
> > 
> > That'll work--but do you really want "/" to be accessible (writeable,
> > even!) over nfs?
> 
> Writable, probably not, not for most anyway.  A very select few,
> perhaps.  But still, probably not even readable for most.  So how to
> solve?  Not export / as the pseudo filesystem?  Or use an ip/netmask
> that makes it impossible to match, or as the one bit of text I read
> offered, bind mount everything you want to export into your "export"
> tree?  This last option seems a bit cumbersome given that everything I
> want to export is already mounted and available under /.

Unfortunately that last option's the only practical approach right now.
We're working to simplify this.

> Is there any way to limit/match on krb5 principals rather than IPs?

No.  You can use ordinary file permissions on the exported files and
directories, assuming the principal names are of the form
local-user-name@REALM.

> So in the situation of exporting / as fsid 0 (but this would be equally
> applicable to an "/export" configuration that bind mounted a filesystem
> under /export and then bind mounted a filesystem under that) given that
> I have other filesystems mounted under / that I want to export as well,
> (i.e. /usr) it's seemed necessary to use the "crossmnt" option on the
> fsid 0 export.  Is this correct?

Yes.

> So if I do export / as fsid=0,ro my guess is that I have to also export
> any subdirs that I want to make "rw" separately,

Right.

> and mount them separately on the client.  i.e.

If you want to.  If you want to just mount the whole of / at one point
in the client filesystem, you can also do that, and the client will
automatically mount the filesystems underneath as it traverses into
them.

> 
> /	10.75.22.0/24(sec=krb5,ro,insecure,sync,wdelay,no_subtree_check,root_squash,fsid=0,crossmnt)
> /home   10.75.22.0/24(sec=krb5,rw,no_root_squash,sync,no_subtree_check)
> /d      10.75.22.0/24(sec=krb5,rw,no_root_squash,sync,no_subtree_check,crossmnt)
> /d/sub  pc(sec=krb5,rw,no_root_squash,sync,no_subtree_check)
> 
> and on the clinet:
> 
> pc # mount -t nfs4 -o sec=krb5 server:/ /mnt/server
> pc # mount -t nfs4 -o sec=krb5 server:/home /mnt/server/home
> pc # mount -t nfs4 -o sec=krb5 server:/d /d
> pc # mount -t nfs4 -o sec=krb5 server:/d/sub /d/sub
> 
> To have /home rw under /mnt/server.  It would be there but ro without
> the second mount, yes?
> 
> It also appears that for the above case of /d and /d/sub I need the
> crossmnt option on /d or I don't see anything in /d/sub even though I've
> exported and mounted it individually.  Does this seem like the expected
> behaviour or a bug?

That's expected.

> It's important to be able to do because I might
> want to be able to export /d to certain hosts without giving them access
> to mountpoints within /d as I have done above with /d/sub and pc.  If I
> use crossmnt which my experience is showing I need, then /d/sub is
> exposed to all of 10.75.22.0/24 which is not what I want.

If you add a separate export for /d/sub, I think it should override that
behavior.  I haven't looked at that recently.

--b.
