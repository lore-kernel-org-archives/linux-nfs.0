From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: [NFS] Export especific file extension
Date: Tue, 28 Jul 2009 07:20:00 -0600
Message-ID: <4A6EFB00.2080308@hp.com>
References: <4A6E0E9F.3010009@gmail.com> <4A6E281F.4020209@hp.com>
	<4A6EDBC9.6040008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: =?ISO-8859-1?Q?=22F=E1bio_Jr=2E=22?= <fjuniorlista@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51581 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbZG1NVH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 09:21:07 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVmbi-0001TI-0A
	for linux-nfs@vger.kernel.org; Tue, 28 Jul 2009 23:20:42 +1000
In-Reply-To: <4A6EDBC9.6040008@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46=E1bio Jr. wrote:
> Rob Gardner escreveu:
>  =20
>> F=E1bio Jr. wrote:
>>    =20
>>> Hello all.
>>>
>>> Is there a way to export only some specific file extensions from a=20
>>> directory, like exporting only the files in /home/fabio with the .j=
pg=20
>>> extension?
>>>      =20
>> You could do this pretty easily by exporting a 'fuse' filesystem=20
>> layered on top of your home directory.
>>
>> Rob Gardner
>> HP
>>
>>    =20
> Thanks Rob for the reply,
>
> This means that if I use this FUSE, I can export via NFS only the fil=
e=20
> extension that I need? let me explain my problem, not really a proble=
m,=20
> but a doubt.
>
> I have one storage that have my aplication files. This storage is=20
> mounted via NFS in my 3 aplication servers. Now I will put another=20
> server, to serve only static files (jpg,png,css,js basically), and=20
> though that maybe there is a way to export only these files from the=20
> storage. The problem is that these files are not organized in diferen=
t=20
> folders.
>
> Maybe my first question doesn't explained my real necessity, but your=
=20
> answer will make me search a little more about FUSE.

I think your first question explained your need clearly. FUSE is a=20
filesystem layer that lets you filter requests through a user program=20
such as a python script. So, for instance, every time a process opens a=
=20
file, a function is called in your script, and you can look at the name=
=20
of the file being opened, and there decide whether or not to allow the=20
file to be opened. I think this would solve your problem easily. Though=
=20
all the storage is "exported", only files with certain names (ie, *.jpg=
,=20
etc) could be opened. You could also decide which files get enumerated=20
with readdir, etc.

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

