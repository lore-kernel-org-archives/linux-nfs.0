From: =?ISO-8859-1?Q?=22F=E1bio_Jr=2E=22?= <fjuniorlista@gmail.com>
Subject: Re: [NFS] Export especific file extension
Date: Tue, 28 Jul 2009 10:36:41 -0300
Message-ID: <4A6EFEE9.1070708@gmail.com>
References: <4A6E0E9F.3010009@gmail.com> <4A6E281F.4020209@hp.com>
	<4A6EDBC9.6040008@gmail.com> <4A6EFB00.2080308@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:55523 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752703AbZG1Noh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 09:44:37 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVmyS-0001tv-MF
	for linux-nfs@vger.kernel.org; Tue, 28 Jul 2009 23:44:12 +1000
In-Reply-To: <4A6EFB00.2080308@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rob Gardner escreveu:
> F=E1bio Jr. wrote:
>> Rob Gardner escreveu:
>> =20
>>> F=E1bio Jr. wrote:
>>>   =20
>>>> Hello all.
>>>>
>>>> Is there a way to export only some specific file extensions from a=
=20
>>>> directory, like exporting only the files in /home/fabio with the=20
>>>> .jpg extension?
>>>>      =20
>>> You could do this pretty easily by exporting a 'fuse' filesystem=20
>>> layered on top of your home directory.
>>>
>>> Rob Gardner
>>> HP
>>>
>>>    =20
>> Thanks Rob for the reply,
>>
>> This means that if I use this FUSE, I can export via NFS only the=20
>> file extension that I need? let me explain my problem, not really a=20
>> problem, but a doubt.
>>
>> I have one storage that have my aplication files. This storage is=20
>> mounted via NFS in my 3 aplication servers. Now I will put another=20
>> server, to serve only static files (jpg,png,css,js basically), and=20
>> though that maybe there is a way to export only these files from the=
=20
>> storage. The problem is that these files are not organized in=20
>> diferent folders.
>>
>> Maybe my first question doesn't explained my real necessity, but you=
r=20
>> answer will make me search a little more about FUSE.
>
> I think your first question explained your need clearly. FUSE is a=20
> filesystem layer that lets you filter requests through a user program=
=20
> such as a python script. So, for instance, every time a process opens=
=20
> a file, a function is called in your script, and you can look at the=20
> name of the file being opened, and there decide whether or not to=20
> allow the file to be opened. I think this would solve your problem=20
> easily. Though all the storage is "exported", only files with certain=
=20
> names (ie, *.jpg, etc) could be opened. You could also decide which=20
> files get enumerated with readdir, etc.
>
> Rob Gardner
> HP
>
>
Oh yes, I think I didn't understand you answer.. but now all became=20
clear in my mind. I'm afraid that using this solution maybe cause an=20
increase on storage processor load, because for every request the scrip=
t=20
must be executed. I already have some issues with server availability,=20
and perhaps the solution of a problem becomes the worsening of another.

Still thanks for the reply and thanks for helping to clear my mind.

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

