From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: [NFS] Export especific file extension
Date: Mon, 27 Jul 2009 16:20:15 -0600
Message-ID: <4A6E281F.4020209@hp.com>
References: <4A6E0E9F.3010009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: =?ISO-8859-1?Q?=22F=E1bio_Jr=2E=22?= <fjuniorlista@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34317 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754831AbZG0WUw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2009 18:20:52 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVYYX-0007Oz-Fo
	for linux-nfs@vger.kernel.org; Tue, 28 Jul 2009 08:20:29 +1000
In-Reply-To: <4A6E0E9F.3010009@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46=E1bio Jr. wrote:
> Hello all.
>
> Is there a way to export only some specific file extensions from a=20
> directory, like exporting only the files in /home/fabio with the .jpg=
=20
> extension?
You could do this pretty easily by exporting a 'fuse' filesystem layere=
d=20
on top of your home directory.

Rob Gardner
HP


-----------------------------------------------------------------------=
-------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30=
-Day=20
trial. Simplify your report design, integration and deployment - and fo=
cus on=20
what you do best, core application coding. Discover what's new with=20
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

