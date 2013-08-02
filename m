Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab3HBOXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 10:23:16 -0400
Subject: Re: Trouble with kerberized NFS client after upgrading from
 nfs-utils 1.2.0 to 1.2.5
From: Simo Sorce <simo@redhat.com>
To: Rohit Mehta <rohitm@engr.uconn.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <51FBA2FD.7070704@engr.uconn.edu>
References: <51FAC933.40508@engr.uconn.edu>
	 <1375391193.15733.213.camel@willson.li.ssimo.org>
	 <51FB0946.5020505@engr.uconn.edu>
	 <1375410802.15733.216.camel@willson.li.ssimo.org>
	 <51FBA2FD.7070704@engr.uconn.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 02 Aug 2013 10:23:13 -0400
Message-ID: <1375453393.15733.255.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-08-02 at 08:15 -0400, Rohit Mehta wrote:
> Thanks Simo,  I apologize for the copy and paste error.  You are 
> correct  about it being "ldd /usr/sbin/rpc.gssd" command.
> 
> The actual error message we get is from the mount command:
> mount.nfs: access denied by server while mounting 
> hnas.engr.uconn.edu:/EngrUser/users/rohitm
> 
> I got a little more output with mount -v
> root@c27-00:~# mount -vvv hnas.engr.uconn.edu:/EngrUser/users/rohitm 
> /foo -o sec=krb5
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: no type was given - I'll assume nfs because of the colon
> mount: spec: "hnas.engr.uconn.edu:/EngrUser/users/rohitm"
> mount: node:  "/foo"
> mount: types: "nfs"
> mount: opts:  "sec=krb5"
> mount: external mount: argv[0] = "/sbin/mount.nfs"
> mount: external mount: argv[1] = 
> "hnas.engr.uconn.edu:/EngrUser/users/rohitm"
> mount: external mount: argv[2] = "/foo"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,sec=krb5"
> mount.nfs: timeout set for Fri Aug  2 08:04:08 2013
> mount.nfs: trying text-based options 
> 'sec=krb5,vers=4,addr=137.99.203.4,clientaddr=137.99.2.29'
> mount.nfs: mount(2): Permission denied
> mount.nfs: access denied by server while mounting 
> hnas.engr.uconn.edu:/EngrUser/users/rohitm
> 
> So there is unfortunately no more info available from mount command and 
> rpc.gssd output did not have any red flags for me. I'm trying to find 
> out if there is a way to get more information from the NFS server 
> itself, but as of now I'm not sure how to do that.

It looks like you have to look at the server side here.
Bump up rpc.svcgssd (or whatever is used on your server) debug and maybe
even the kernel log with the rpcdebug command and see why it is refusing
your authentication.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

