From: =?ISO-8859-1?Q?=22F=E1bio_Jr=2E=22?= <fjuniorlista@gmail.com>
Subject: Re: [NFS] Export especific file extension
Date: Tue, 28 Jul 2009 08:06:49 -0300
Message-ID: <4A6EDBC9.6040008@gmail.com>
References: <4A6E0E9F.3010009@gmail.com> <4A6E281F.4020209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54266 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbZG1LHy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 07:07:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVkWo-0007Pq-AR
	for linux-nfs@vger.kernel.org; Tue, 28 Jul 2009 21:07:30 +1000
In-Reply-To: <4A6E281F.4020209@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rob Gardner escreveu:
> F=E1bio Jr. wrote:
>> Hello all.
>>
>> Is there a way to export only some specific file extensions from a=20
>> directory, like exporting only the files in /home/fabio with the .jp=
g=20
>> extension?
> You could do this pretty easily by exporting a 'fuse' filesystem=20
> layered on top of your home directory.
>
> Rob Gardner
> HP
>
Thanks Rob for the reply,

This means that if I use this FUSE, I can export via NFS only the file=20
extension that I need? let me explain my problem, not really a problem,=
=20
but a doubt.

I have one storage that have my aplication files. This storage is=20
mounted via NFS in my 3 aplication servers. Now I will put another=20
server, to serve only static files (jpg,png,css,js basically), and=20
though that maybe there is a way to export only these files from the=20
storage. The problem is that these files are not organized in diferent=20
folders.

Maybe my first question doesn't explained my real necessity, but your=20
answer will make me search a little more about FUSE.

Thanks.

[]s

=46=E1bio Jr.


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

