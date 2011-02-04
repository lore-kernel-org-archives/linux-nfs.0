Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34323 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748Ab1BDJb0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Feb 2011 04:31:26 -0500
Received: by wyb28 with SMTP id 28so2050032wyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Feb 2011 01:31:25 -0800 (PST)
In-Reply-To: <20110201181510.GA25136@fieldses.org>
References: <AANLkTinD01zA=DTXEDG5pXVYcrEGsWOyXcMta0rzvB6n@mail.gmail.com>
 <AANLkTimA-sCz8LQLu1weh-qQOm30jHYyO3qtxmPDPX98@mail.gmail.com> <20110201181510.GA25136@fieldses.org>
From: camden lindsay <camden.lindsay@gmail.com>
Date: Fri, 4 Feb 2011 01:31:05 -0800
Message-ID: <AANLkTimzQ4ajWtPCCT3M9L7SFmijMiM2hdSJss5jqeoo@mail.gmail.com>
Subject: Re: clients cannot reconnect to mounted nfs shares after server restart
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for the response:
I have waited quite some time-- many minutes-- and still cannot reconnect.

Server --> BigBox dylan # uname -a
Linux BigBox 2.6.36-gentoo-r5 #5 SMP Tue Feb 1 06:57:03 PST 2011
x86_64 Intel(R) Core(TM) i3 CPU 540 @ 3.07GHz GenuineIntel GNU/Linux

What i have found is that, with a newer client, i get slightly more
information at the command line, pointing to stale nfs filehandle:
Client1:
Linux shobuntu 2.6.24-28-generic #1 SMP Wed Nov 24 09:30:14 UTC 2010
i686 GNU/Linux
mount.nfs: timeout set for Fri Feb  4 01:19:37 2011
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: text-based options: 'addr=192.168.11.10'

Client2:
Linux core2buntu 2.6.32-28-generic #55-Ubuntu SMP Mon Jan 10 23:42:43
UTC 2011 x86_64 GNU/Linux
mount.nfs: timeout set for Fri Feb  4 01:18:17 2011
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: mount(2): Stale NFS file handle
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: mount(2): Stale NFS file handle
mount.nfs: text-based options: 'addr=192.168.11.10'
mount.nfs: mount(2): Stale NFS file handle


Should this automatically converge at some point?
If so, how long should i expect for convergence?

Thanks!
Camden

On Tue, Feb 1, 2011 at 10:15 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Mon, Jan 31, 2011 at 07:24:30PM -0800, camden lindsay wrote:
> > Having an issue i believe is an NFS bug, but would like someone to
> > verify as well as... point me the correct direction to submit a bug as
> > needed if it indeed is.
> > Situation:
> > NFS server running
> > Client connected with mounted share
> > NFS server is shut down -- (halt or /etc/init.d/nfs stop)
> > NFS server is turned on (booted or /etc/init.d/nfs start)
> >
> > Outcome:
> > NFS client that was connected does not reconnect to that share automatically
> > NFS client that was connected cannot reconnect via umount then mount again
> > No other nfs client can connect to that share, before or after origial
>
> How long have you waited?
>
> > NFS clients attempts to connect/reconnect
> > NFS clients CAN connect to a different share.
> > Details/logs:
> > Server shows that client is authenticating:
> > Feb  1 03:01:47 BigBox mountd[6557]: authenticated mount request from
> > 192.168.11.49:674 for /mnt/store/public (/mnt/store/public)
> > Feb  1 03:01:48 BigBox mountd[6557]: authenticated mount request from
> > 192.168.11.49:763 for /mnt/store/public (/mnt/store/public)
> > Feb  1 03:01:50 BigBox mountd[6557]: authenticated mount request from
> > 192.168.11.49:932 for /mnt/store/public (/mnt/store/public)
> > Feb  1 03:01:54 BigBox mountd[6557]: authenticated mount request from
> > 192.168.11.49:942 for /mnt/store/public (/mnt/store/public)
>
> A network trace (tcpdump -s0 -wtmp.pcap, then reproduce the problem,
> then ^C tcpdump, then send us tmp.pcap) might help.
>
> >
> > Client shows retransmission:
> > dylan@shobuntu:~$ sudo mount -v -t nfs bigbox:/mnt/store/public Public/
> > mount.nfs: timeout set for Mon Jan 31 19:09:32 2011
> > mount.nfs: text-based options: 'addr=192.168.11.10'
> > mount.nfs: text-based options: 'addr=192.168.11.10'
> > mount.nfs: text-based options: 'addr=192.168.11.10'
> > mount.nfs: text-based options: 'addr=192.168.11.10'
> > mount.nfs: text-based options: 'addr=192.168.11.10'
> >
> > Server Version:
> > net-fs/nfs-utils
> >       Latest version available: 1.1.4-r1
> >       Latest version installed: 1.1.4-r1
> >       Size of files: 574 kB
> >       Homepage:      http://linux-nfs.org/
> >       Description:   NFS client and server daemons
> >       License:       GPL-2
> > (server is on Gentoo, client on Ubuntu)
>
> Note most of the NFS code is actually in the kernel, so the kernel
> version(s) involved would be useful too.
>
> --b.
>
> > Thanks!
> > Camden
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
