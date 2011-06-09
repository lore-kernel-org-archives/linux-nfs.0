Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp09.online.nl ([194.134.42.54]:32795 "EHLO smtp09.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab1FIFCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 01:02:18 -0400
Subject: Re: NFS3 + kerberos: performance issues
From: Vladimir Elisseev <vovan@vovan.nl>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110608162449.GD4101@fieldses.org>
References: <1307086159.1052.19.camel@vovan.net.home>
	 <1307104354.2477.17.camel@lade.trondhjem.org>
	 <1307123836.1052.23.camel@vovan.net.home>
	 <20110607230754.GF13911@fieldses.org>
	 <1307514377.1533.35.camel@vovan.net.home>
	 <20110608153950.GB4101@fieldses.org>
	 <1307548836.1533.46.camel@vovan.net.home>
	 <20110608162449.GD4101@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 09 Jun 2011 07:02:15 +0200
Message-ID: <1307595735.1533.62.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This morning I've decided to redo all the tests and include some more
statistics ( mountstat and vmstat ). However, when I exported the same
mount point with different options I missed one _very_ important option.
This option was presented for the export with sec=sys, but omitted with
sec=krb5. The option is "async"... I promise to be more careful before
posting any results. Thanks all of you for the help and I'm sorry to
trouble you.

Regards,
Vlad.


On Wed, 2011-06-08 at 12:24 -0400, J. Bruce Fields wrote:
> On Wed, Jun 08, 2011 at 06:00:36PM +0200, Vladimir Elisseev wrote:
> > Thanks for pointing me to the right to look at. However, the main point
> > is huge performance degradation while using sec=krb5 option instead of
> > sec=sys. With sec=sys everything works as expected. Personally I simply
> > can't find any reasonable explanation.
> 
> Right, me neither.  That's why I suggest a) looking at mountstats, to
> figure out which rpc operations are taking longer in the sec=krb5 case
> than they are in the sec=sys case, and b) looking at server-side
> statistics (mainly cpu usage, I guess) to start looking for bottlenecks
> on the server.
> 
> --b.
> 
> > BTW, I'm using Gentoo and getting
> > the same error while using mountstats script.
> > 
> > Regards,
> > Vlad.
> > 
> > On Wed, 2011-06-08 at 11:39 -0400, J. Bruce Fields wrote:
> > > On Wed, Jun 08, 2011 at 08:26:17AM +0200, Vladimir Elisseev wrote:
> > > > All of the accounts, except very limited amount, are in LDAP, and as I
> > > > can see user information is identical on server and client. As for my
> > > > tests, below are all the details. Difference in speed while copying a
> > > > lot of small files is _huge_... I'd appreciate if somebody more familiar
> > > > with NFS/kerberos combination can provide a kind of explanation. 
> > > > 
> > > > Regards,
> > > > Vlad.
> > > > 
> > > > * Local directory is /mnt/data/tmp/coreboot/src
> > > > # find x86/ | wc -l
> > > > 296
> > > > # du -csh x86
> > > > 1.5M	x86
> > > > 1.5M	total
> > > > * First try without kerberos: grep /mnt/tmp/ /proc/mounts
> > > > nfs:/mnt/tmp /mnt/tmp nfs
> > > > rw,noatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.219,mountvers=3,mountport=32767,mountproto=tcp,local_lock=none,addr=192.168.1.219 0 0
> > > > # time cp -i -arv /mnt/data/tmp/coreboot/src/arch/x86 /mnt/tmp/x86 
> > > > cp -i -arv /mnt/data/tmp/coreboot/src/arch/x86 /mnt/tmp/x86 0.01s user
> > > > 0.04s system 10% cpu 0.476 total
> > > > 
> > > > * Second try with kerberos: grep /mnt/tmp/ /proc/mounts
> > > > nfs:/mnt/tmp /mnt/tmp nfs
> > > > rw,noatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5,mountaddr=192.168.1.219,mountvers=3,mountport=32767,mountproto=tcp,local_lock=none,addr=192.168.1.219 0 0
> > > > # time cp -i -arv /mnt/data/tmp/coreboot/src/arch/x86 /mnt/tmp/x86 
> > > > cp -i -arv /mnt/data/tmp/coreboot/src/arch/x86 /mnt/tmp/x86  0.01s user
> > > > 0.07s system 0% cpu 23.294 total
> > > 
> > > So if I'm reading that right, the client isn't doing any more work, it's
> > > just taking longer, so presumably it's spending more time waiting for
> > > the server.
> > > 
> > > Might be worth looking at /proc/self/mountstats to see which rpc's are
> > > taking longer.
> > > 
> > > (Chuck, what's up with the mountstats script?  On a fedora 15 machine
> > > with mountstats installed, it gives me "Statistics for mount point /mnt
> > > not found", but
> > > 
> > > 	# grep mnt /proc/self/mountstats 
> > > 	pip1:/exports/ mounted on /mnt with fstype nfs4 statvers=1.0
> > > 
> > > On a ubuntu machine running the mountstats out of
> > > nfs-utils/tools/mountstats/mountstats.py, it runs without any output.)
> > > 
> > > Might also be worth looking at vmstat or something on the server.
> > > 
> > > --b.
> > > 
> > > 
> > > > 
> > > > At the same time test with a single file (621M):
> > > > * without kerberos: 
> > > > cp -i -av /mnt/media/images/GNOME_3.x86_64-0.2.0-Build1.1.iso   0.00s
> > > > user 0.69s system 5% cpu 13.521 total
> > > > * with kerberos:
> > > > cp -i -av /mnt/media/images/GNOME_3.x86_64-0.2.0-Build1.1.iso   0.00s
> > > > user 0.55s system 2% cpu 26.299 total
> > > > 
> > > > With the same file, but with "dd
> > > > if=/mnt/media/images/GNOME_3.x86_64-0.2.0-Build1.1.iso
> > > > of=/mnt/tmp/test.iso bs=32M"
> > > > gives:
> > > > * without kerberos: 651165696 bytes (651 MB) copied, 10.7168 s, 60.8
> > > > MB/s
> > > > * with kerberos: 651165696 bytes (651 MB) copied, 24.6176 s, 26.5 MB/s
> > > > 
> > > > 
> > > > On Tue, 2011-06-07 at 19:07 -0400, J. Bruce Fields wrote:
> > > > > On Fri, Jun 03, 2011 at 07:57:16PM +0200, Vladimir Elisseev wrote:
> > > > > > There's no mount command involved in timing. It's simply copy of the
> > > > > > same directory (with many small files to NFS share with and without
> > > > > > sec=krb5 mount option.
> > > > > 
> > > > > Weird.
> > > > > 
> > > > > I wonder if the krb5 principal is being mapped to a different user on
> > > > > the server side, and that's making some difference.
> > > > > 
> > > > > Still, could you give us the full details?  (Exactly what commands are
> > > > > you running, what results do you see?)
> > > > > 
> > > > > --b.
> > > > > --
> > > > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > > > the body of a message to majordomo@vger.kernel.org
> > > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > 
> > 

