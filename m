From: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Thu, 4 Dec 2008 15:16:13 +0100
Message-ID: <200812041516.14114.t.bubeck@reinform.de>
References: <200811281541.39272.t.bubeck@reinform.de> <200812041025.02563.t.bubeck@reinform.de> <4937E243.1080608@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1.reinform.de ([82.141.45.9]:44759 "EHLO
	mail-out.dmz.loef.reinform.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752799AbYLDOQX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 09:16:23 -0500
In-Reply-To: <4937E243.1080608-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's very good that it is fixed in Fedora (my preferred distribution), but it 
is still wrong in SuSe (verified) and probably more.

A better way would be to fix NFS and its utilities itself instead of fixing 
the distribution. This means, that the way the kernel and nfs-utils interact 
should be made more robust (see my posting before).

Till



Am Donnerstag, 4. Dezember 2008 14:59:31 schrieb Steve Dickson:
> Dr. Tilmann Bubeck wrote:
> > Sorry for the confusion. Maybe I can make myself clearer this time:
> >
> > Fedora 10 uses the following simplified /etc/init.d/nfs to start the NFS
> > server:
> >
> >   1. exportfs -r
> >   2. modprobe nfsd
> >      This also does (see modprobe.conf.dist): mount -t nfsd nfsd
> > /proc/fs/nfsd
> >
> > As you can read in "man exportfs" there are two modes: "legacy" and "new"
> > depending on the existance of /proc/fs/nfsd. The above version of
> > /etc/init.d/nfs executes exportfs in lecacy mode and therefore feeds
> > /var/lib/nfs/rmtab into the kernel. After "mount -t nfsd ..." the "new"
> > mode is used. In this case the previously fed rmtab is disturbing because
> > we have a mix of "legacy" and "new" mode. This results in the problem
> > that some NFS clients are receiving a "Stale NFS file handle" after a
> > server reboot.
> >
> > I tracked the problem down to the kernel based export table which is
> > found in /proc/fs/nfsd/exports. The above start order results in:
> >
> > root# cat /proc/fs/nfsd/exports  | grep dhcp-10-1-1-209
> > /home
> > dhcp-10-1-1-209.loef.reinform.de(rw,root_squash,sync,wdelay,no_subtree_ch
> >eck,fsid=1510)
> >
> > which results from "exportfs -r" reading rmtab and feeding into the
> > kernel.
> >
> > By changing the start order to:
> >
> >   1. modprobe nfsd
> >      This also does (see modprobe.conf.dist): mount -t nfsd nfsd
> > /proc/fs/nfsd 2. exportfs -r
> >
> > then "exportfs -r" starts in "new" mode and does not feed the rmtab into
> > the kernel.
>
> This has been fixed in both Fedora 9 and 10... The update nfs-utils version
> should be hitting a yum repository near you soon...
>
> steved.



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
