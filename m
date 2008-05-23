From: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Subject: RE: extremely long time for exportfs to display
Date: Fri, 23 May 2008 13:38:25 -0700
Message-ID: <620E93B2E5CC3B46BD811165E3335B8701271CA7@0461-its-exmb02.us.saic.com>
References: <620E93B2E5CC3B46BD811165E3335B87011F8E9C@0461-its-exmb02.us.saic.com> <20080523152045.GA6276@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cpmx2.mail.saic.com ([139.121.17.172]:47663 "EHLO
	cpmx2.mail.saic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757571AbYEWUfj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2008 16:35:39 -0400
In-Reply-To: <20080523152045.GA6276@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A little history, I have tested the exports file on two servers, one in
production one a test server.  The two servers are modified RHEL4.2.
	production - kernel-smp-2.6.9-67.EL.x86_64
                  nfs-utils-1.0.6-84.EL4.x86_64
                  nfs-utils-lib-1.0.6-8.z1.x86_64
                  util-linux-2.12a-16.EL4.29.x86_64

     test       - kernel-smp-2.6.9-67.0.4.EL.x86_64
                  nfs-utils-1.0.6-84.EL4.x86_64
                  nfs-utils-lib-1.0.6-8.z1.x86_64
                  util-linux-2.12a-16.EL4.29.x86_64

The test server has a slightly newer kernel.  The exports file is large,
186 lines, some lines with 20+ workstation entries.
using strace -t, the two servers look at /etc/resolv.conf, do an lstat
on the exported directories, I am double checking not to see if it is
all directories or not.
On the production server, after the lstat on the directories, there is a
call to open /etc/nsswitch.conf, /etc/host.conf, /etc/hosts, and
/var/yp/binding/domainname.  All of the extra time in within this piece.
On the test server, there never is a call to open nsswitch.conf,
/etc/host.conf, /etc/hosts, or/var/yp/binding/domainname.
I have the strace of the execution of exportfs if needed.

Wayne
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> Sent: Friday, May 23, 2008 10:21 AM
> To: Murata, Dennis
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: extremely long time for exportfs to display
> 
> On Thu, May 22, 2008 at 05:41:05PM -0700, Murata, Dennis wrote:
> > Very recently we have seen a very serious slowdown with the 
> exportfs 
> > command on a file server.  Usually the exportfs -r command or even 
> > just the exportfs command to display the exported 
> directories is very quick.
> > Now it can take 20 minutes to display the exported directories.
> > An strace shows a lookup at /etc/hosts, from yp, and from dns.  The 
> > hosts lookup in /etc/nsswitch is files nis dns, so this is as 
> > expected, the time it is taking is not.
> 
> Have you run strace with something like -t to work out 
> exactly where the time is going?
> 
> --b.
> 
> > The yp slave that the server is bound to seems to be having some 
> > problems, could this be the issue?
> > 
> > Wayne
> > --
> > To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" 
> > in the body of a message to majordomo@vger.kernel.org More 
> majordomo 
> > info at  http://vger.kernel.org/majordomo-info.html
> 
