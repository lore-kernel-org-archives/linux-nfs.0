From: =?ISO-8859-1?Q?=22F=E1bio_Jr=2E=22?= <fjuniorlista@gmail.com>
Subject: Re: [NFS] Export especific file extension
Date: Tue, 28 Jul 2009 11:40:11 -0300
Message-ID: <4A6F0DCB.3090903@gmail.com>
References: <4A6E0E9F.3010009@gmail.com> <4A6E281F.4020209@hp.com>
	<4A6EDBC9.6040008@gmail.com> <4A6EFB00.2080308@hp.com>
	<4A6EFEE9.1070708@gmail.com> <4A6F02F5.9090002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:55144 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbZG1OlC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 10:41:02 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVnr3-0002yS-B7
	for linux-nfs@vger.kernel.org; Wed, 29 Jul 2009 00:40:37 +1000
In-Reply-To: <4A6F02F5.9090002@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rob Gardner escreveu:
> F=E1bio Jr. wrote:
>> Rob Gardner escreveu:
>> =20
>>> F=E1bio Jr. wrote:
>>>   =20
>>>> Rob Gardner escreveu:
>>>> =20
>>>>     =20
>>>>> F=E1bio Jr. wrote:
>>>>>          =20
>>>>>> Hello all.
>>>>>>
>>>>>> Is there a way to export only some specific file extensions from=
=20
>>>>>> a directory, like exporting only the files in /home/fabio with=20
>>>>>> the .jpg extension?
>>>>>>                =20
>>>>> You could do this pretty easily by exporting a 'fuse' filesystem=20
>>>>> layered on top of your home directory.
>>>>>
>>>>> Rob Gardner
>>>>> HP
>>>>>
>>>>>            =20
>>>> Thanks Rob for the reply,
>>>>
>>>> This means that if I use this FUSE, I can export via NFS only the=20
>>>> file extension that I need? let me explain my problem, not really =
a=20
>>>> problem, but a doubt.
>>>>
>>>> I have one storage that have my aplication files. This storage is=20
>>>> mounted via NFS in my 3 aplication servers. Now I will put another=
=20
>>>> server, to serve only static files (jpg,png,css,js basically), and=
=20
>>>> though that maybe there is a way to export only these files from=20
>>>> the storage. The problem is that these files are not organized in=20
>>>> diferent folders.
>>>>
>>>> Maybe my first question doesn't explained my real necessity, but=20
>>>> your answer will make me search a little more about FUSE.
>>>>      =20
>>> I think your first question explained your need clearly. FUSE is a=20
>>> filesystem layer that lets you filter requests through a user=20
>>> program such as a python script. So, for instance, every time a=20
>>> process opens a file, a function is called in your script, and you=20
>>> can look at the name of the file being opened, and there decide=20
>>> whether or not to allow the file to be opened. I think this would=20
>>> solve your problem easily. Though all the storage is "exported",=20
>>> only files with certain names (ie, *.jpg, etc) could be opened. You=
=20
>>> could also decide which files get enumerated with readdir, etc.
>>>
>>> Rob Gardner
>>> HP
>>>
>>>
>>>    =20
>> Oh yes, I think I didn't understand you answer.. but now all became=20
>> clear in my mind. I'm afraid that using this solution maybe cause an=
=20
>> increase on storage processor load, because for every request the=20
>> script must be executed. I already have some issues with server=20
>> availability, and perhaps the solution of a problem becomes the=20
>> worsening of another.
>>
>> Still thanks for the reply and thanks for helping to clear my mind.
>
> It's a valid concern, but fuse does not "execute a script" for every=20
> operation. The script is always running, sort of like a server for th=
e=20
> pseudo-filesystem. Each requests causes a few lines in the script to=20
> be executed. There is no process creation and dispatch for each=20
> operation, only a process wakeup for each operation. It is=20
> impressively lightweight and it's worth trying before dismissing it a=
s=20
> a resource drain.
>
Hmm.. that's interesting, but, how many requests this script can handle=
?=20
This can vary in diferent systems or configs, or even can be measured?
> But anyway, here's another idea for you-- Export a new directory that=
=20
> contains links to only those the files you want to export.
>
Unfortunately, even if I wanted to, it's not possible to do this in my=20
scenario, since I have aprox. 4 milion files only in jpeg format in=20
different folders, not counting the other extensions. The major problem=
=20
was the planning phase, that not counted with so many files and not=20
prepared the files organization to better performance. But for smallers=
=20
systems, its a very good solution.

[]s

=46=E1bio jr.

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

