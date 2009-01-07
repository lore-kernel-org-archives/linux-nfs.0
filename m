From: Felix Bolte <gockelhahn@hotmail.com>
Subject: exporting loop devices / fsid issue
Date: Wed, 7 Jan 2009 11:56:53 +0100
Message-ID: <BLU106-W57D668101BC034E6586C60C9DF0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blu0-omc3-s18.blu0.hotmail.com ([65.55.116.93]:17616 "EHLO
	blu0-omc3-s18.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbZAGLDE convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2009 06:03:04 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi all,

in the last time I've been playing around with loop devices and figured out some problems by using NFS.

My situation is now that i have two identical but independent iso files with different inode numbers.
I attached them to different loop devices and mounted them to the filesystem: iso1 -> /dev/loop1 -> /export/1, iso2 -> /dev/loop2 -> /export/2.
For later understanding, at this time the files inside the two mounted directories have the same inode numbers.

I want to export the content of the mounted iso files with NFS. My /etc/exports looks like:

    /export/1        *(rw,no_root_squash,no_subtree_check)
    /export/2        *(rw,no_root_squash,no_subtree_check)

The major device id of loop is 7 (see /proc/devices). The minor device ids are 1 (/dev/loop1) and 2 (/dev/loop2).
With that information we know that each export has its own fsid which consists of major and minor number of the related device.

I sniffed the NFS traffic with wireshark on mounting the exports on the client machine as /mnt/1 and /mnt/2.

The result is:

CentOS 5.2 with kernel 2.6.18 (+ backports):
    fsid: 0x0000000000000701
    fsid: 0x0000000000000702
Sles 10 SP2 with kernel 2.6.16 (+ backports):
    fsid: 0x0000000000000701
    fsid: 0x0000000000000702

You can see the major and minor number are parts of the fsid.

When you look at point 3.1 in

    http://www.fsl.cs.sunysb.edu/docs/nfscrack-tr/index.html

The filehandle of a file should include the major and minor number of the exported device. In our case 00 07 00 01 and 00 07 00 02.
The filehandle of the mounted directory /mnt/1 is (hex)01 00 00 00 00 07 00 01 02 00 00 00. From the 5th to the 8th byte we can find our major and minor ids.

Great! I have two exports with a different fsid but the same inode numbers. They are distinguishable. Works as expected.

But it doesn't work on newer kernels. I don't know why, but the fsid changed to something random, which is not worse, but for both exports we have now the same fsid.
Same fsid + same inode number == same filehandle. Although i mounted the two directories separately, i can only change the first one, because the seconds maps to the first too.

Ubuntu 8.04 (kernel 2.6.24):
    fsid: 0xf4fc911be355fa99
    fsid: 0xf4fc911be355fa99
OpenSuse 11.1 (kernel 2.6.27):
    fsid: 0xf4fc911be355fa99
    fsid: 0xf4fc911be355fa99

Ok, this point wasn't clear to me. Could be that the fsid naming was changed. I found out there's an option to manually set an fsid to my exports. /etc/exports now looks like:

    /export/1        *(fsid=10,rw,no_root_squash,no_subtree_check)
    /export/2        *(fsid=11,rw,no_root_squash,no_subtree_check)

I mounted them again on the client machine. There is still the same problem, they have the same content. If I rename a file in /mnt/2, it is also renamed in /mnt/1.

Again sniffing the network packets. The fsid of the first export was 0x0000000000000000a (which is 10 in decimal) as it should be, but the fsid on the second one was also 0x0a instead of 0x0b (decimal 11).


Have there been any changes in the nfs-kernel-server implementation? In my tests kernels 2.6.16/18 work, but 2.6.24/27 don't. The nfs-user-server works too.

Did I miss anything? Do I have a conceptional problem? Do you need more information for debugging?

I appreciate every hint to solve this problem.



Thanks!

Felix Bolte


_________________________________________________________________
http://redirect.gimas.net/?n=M0901xFTPMultimedia
Ihr PC kann mehr! Home Entertainment leicht gemacht.