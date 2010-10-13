Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896Ab0JMOtA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 10:49:00 -0400
Date: Wed, 13 Oct 2010 10:49:37 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Valentijn Sessink <valentyn@blub.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
Message-ID: <20101013104937.358fe122@corrin.poochiereds.net>
In-Reply-To: <4CB5BA8F.2090608@blub.net>
References: <4CB59086.9080108@blub.net>
	<20101013125656.GA5197@merit.edu>
	<20101013095216.5b9b31a7@corrin.poochiereds.net>
	<4CB5BA8F.2090608@blub.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 13 Oct 2010 15:56:31 +0200
Valentijn Sessink <valentyn@blub.net> wrote:

> Jeff Layton schreef:
> > As of nfs-utils-1.2.3, IPv6 server-side support should be
> > "complete" (modulo bugs, of course).
> 
> Which is "correct" (I copied the quotation marks, because I tested very
> inextensively). What I'm wondering about is the combination with
> Kerberos. I'm currently setting up a better testing environment.
> 
> V.
> 

FWIW, I was planning on doing some testing of this soon anyway. It
works for me:

>From /proc/mounts:

rhel6srv.example.com:/export/ /mnt/test nfs4 rw,relatime,vers=4,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp6,port=0,timeo=600,retrans=2,sec=krb5,clientaddr=feed::3,minorversion=0,addr=feed::4 0 0

$ klist
Ticket cache: FILE:/tmp/krb5cc_50000
Default principal: testuser@EXAMPLE.COM

Valid starting     Expires            Service principal
10/13/10 10:43:48  10/14/10 10:43:46  krbtgt/EXAMPLE.COM@EXAMPLE.COM
	renew until 10/13/10 10:43:48
10/13/10 10:43:58  10/14/10 10:43:46  nfs/rhel6srv.example.com@EXAMPLE.COM
	renew until 10/13/10 10:43:48

$ id -a
uid=50000(testuser) gid=50000(testuser) groups=50000(testuser) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

$ cd /mnt/test; echo foo > testuser ; stat testuser
  File: `testuser'
  Size: 4         	Blocks: 0          IO Block: 131072 regular file
Device: 15h/21d	Inode: 29          Links: 1
Access: (0664/-rw-rw-r--)  Uid: (50000/testuser)   Gid: (50000/testuser)
Access: 2010-10-13 10:47:07.771053989 -0400
Modify: 2010-10-13 10:47:07.802186619 -0400
Change: 2010-10-13 10:47:07.802186619 -0400

It sounds more like you have a problem with idmapping rather than
anything krb5 specific, but I'm not sure why that would be the case
with sec=krb5 and not with sec=sys.

-- 
Jeff Layton <jlayton@redhat.com>
