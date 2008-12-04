From: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Thu, 4 Dec 2008 10:25:01 +0100
Message-ID: <200812041025.02563.t.bubeck@reinform.de>
References: <200811281541.39272.t.bubeck@reinform.de> <200811281705.45087.t.bubeck@reinform.de> <20081203172518.GD16846@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1.reinform.de ([82.141.45.9]:36627 "EHLO
	mail-out.dmz.loef.reinform.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753109AbYLDJZN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 04:25:13 -0500
In-Reply-To: <20081203172518.GD16846@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the confusion. Maybe I can make myself clearer this time:

Fedora 10 uses the following simplified /etc/init.d/nfs to start the NFS 
server:

  1. exportfs -r
  2. modprobe nfsd
     This also does (see modprobe.conf.dist): mount -t nfsd nfsd /proc/fs/nfsd

As you can read in "man exportfs" there are two modes: "legacy" and "new"
depending on the existance of /proc/fs/nfsd. The above version of
/etc/init.d/nfs executes exportfs in lecacy mode and therefore feeds
/var/lib/nfs/rmtab into the kernel. After "mount -t nfsd ..." the "new" mode 
is used. In this case the previously fed rmtab is disturbing because we have 
a mix of "legacy" and "new" mode. This results in the problem that some NFS 
clients are receiving a "Stale NFS file handle" after a server reboot.

I tracked the problem down to the kernel based export table which is found 
in /proc/fs/nfsd/exports. The above start order results in:

root# cat /proc/fs/nfsd/exports  | grep dhcp-10-1-1-209
/home   
dhcp-10-1-1-209.loef.reinform.de(rw,root_squash,sync,wdelay,no_subtree_check,fsid=1510)

which results from "exportfs -r" reading rmtab and feeding into the kernel.

By changing the start order to:

  1. modprobe nfsd
     This also does (see modprobe.conf.dist): mount -t nfsd nfsd /proc/fs/nfsd
  2. exportfs -r

then "exportfs -r" starts in "new" mode and does not feed the rmtab into the 
kernel. Therefore the kernel export table is:

root# cat /proc/fs/nfsd/exports 
# Version 1.1
# Path Client(Flags) # IPs
/home   10.0.0.0/8
(rw,root_squash,sync,wdelay,no_subtree_check,fsid=1510,uuid=bd6c73cb:12de4994:8aaba0c5:cc82b618)

This does not give a stale NFS file handle on the client. If the uuid is 
missing, it results in stale NFS file handles.

The problem could be healed by issuing "exportfs -f" as a workaround to clear 
the kernel export tabel. But this is not a good solution, because all NFS 
clients already had a "Stale NFS file handle". But they reconnect correctly 
after "exportfs -f".

First I want to make sure, that the above is indeed correct. I successfully 
verified this on my own systems.

If you think it is correct, then someone should probably fix the "legacy" mode 
of "exportfs -r" to include/generate a uuid or fix the kernel to generate it 
accordingly to the new mode. Maybe something better could be found.

I do think, that the two modes "lecacy" and "new" should be made in a way, 
that they do not interfere with each other. Otherwise the manual pages or 
distributions should be told very clear how to avoid the problem.

I'm glad for any reponse to the above ideas.

Till


Am Mittwoch, 3. Dezember 2008 18:25:18 schrieb J. Bruce Fields:
> On Fri, Nov 28, 2008 at 05:05:44PM +0100, Dr. Tilmann Bubeck wrote:
> > To be more precise: the order between "exportfs -r" and "modprobe nfsd"
> > is important (and not "exportfs -r" and "rpc.mountd").
>
> So, I'm confused: what are the before-and-after orders of all three
> (modprobe, exportfs, and rpc.mountd)?
>
> > Am Freitag, 28. November 2008 15:41:38 schrieb Dr. Tilmann Bubeck:
> > > According to manual page "exportfs -r" has two modes: legacy and new.
> > > Fedora 10 seems to use the new mode and mounts /proc/fs/nfsd.
> > >
> > > But they use the following order in /etc/init.d/nfs:
> > >   exportfs -r
> > >   rpc.mountd
> > >
> > > This results in /proc/fs/nfsd/exports having all obsolete entries
> > > from /var/lib/nfs/rmtab which causes a lot of trouble with stale NFS
> > > file handles.
>
> What problems exactly?
>
> > > This seems to be wrong according to "man exportfs" in new mode.
> > >
> > > If I change the order to
> > >   rpc.mountd
> > >   exportfs -r
> > >
> > > then everything is OK and /proc/fs/nfsd/exports only contains the info
> > > from /etc/exports and not all stale clients. This seems to be correct
> > > according to "man exportfs" in new mode.
> > >
> > > Questions: is this behaviour a bug or at least bad? Shouldn't exportfs
> > > being changed, so that when it detects "new" mode it will never feed
> > > rmtab into the kernel and rely upon rpc.mountd answering the kernels
> > > questions as stated in "man exportfs"?
>
> That does sound wrong.
>
> Perhaps rmtab should also be cleared on exportfs -r?  I don't really
> understand how rmtab should work.
>
> --b.
>
> > > If yes, then the order or the programs is irrelevant.
> > > If not, should the order of the programs be reversed in Fedora?
> > >
> > > Thanks
> > >  Till
> >
> > --
> > +-------+-------------------------------------------------------------+
> >
> > |       | dr. tilmann bubeck               reinform medien- und       |
> > |       |                                  informationstechnologie AG |
> > |
> > | rein  | fon  : +49 (711) 7 82 76-52      loeffelstr. 40             |
> > | form  | fax  : +49 (711) 7 82 76-46      70597 stuttgart / germany  |
> > |    AG | cell.: +49 (172) 8 84 29 72      fon: +49 (711) 75 86 56-10 |
> > |
> > |       | email: t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org      http://www.reinform.de     |
> > |
> > |       +-------------------------------------------------------------+
> > |
> > |       | pflichtangaben nach paragraph 80, AktG:                     |
> > |       | reinform medien- und informationstechnologie AG, stuttgart  |
> > |       | handelsregister stuttgart, HRB 23001                        |
> > |       | vorstand:     dr. tilmann bubeck (vorsitz), dr. tommy kuhn  |
> > |       | aufsichtsrat: frank stege (vorsitz)                         |
> >
> > +-------+-------------------------------------------------------------+
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
+-------+-------------------------------------------------------------+
|       | dr. tilmann bubeck               reinform medien- und       |
|       |                                  informationstechnologie AG |
| rein  | fon  : +49 (711) 7 82 76-52      loeffelstr. 40             |
| form  | fax  : +49 (711) 7 82 76-46      70597 stuttgart / germany  |
|    AG | cell.: +49 (172) 8 84 29 72      fon: +49 (711) 75 86 56-10 |
|       | email: t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org      http://www.reinform.de     |
|       +-------------------------------------------------------------+
|       | pflichtangaben nach paragraph 80, AktG:                     |
|       | reinform medien- und informationstechnologie AG, stuttgart  |
|       | handelsregister stuttgart, HRB 23001                        |
|       | vorstand:     dr. tilmann bubeck (vorsitz), dr. tommy kuhn  |
|       | aufsichtsrat: frank stege (vorsitz)                         |
+-------+-------------------------------------------------------------+
