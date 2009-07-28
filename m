From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: [NFS] Export especific file extension
Date: Tue, 28 Jul 2009 09:58:16 -0600
Message-ID: <4A6F2018.1040808@hp.com>
References: <4A6E0E9F.3010009@gmail.com> <4A6E281F.4020209@hp.com>
	<4A6EDBC9.6040008@gmail.com> <4A6EFB00.2080308@hp.com>
	<4A6EFEE9.1070708@gmail.com> <4A6F02F5.9090002@hp.com>
	<4A6F0DCB.3090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: =?ISO-8859-1?Q?=22F=E1bio_Jr=2E=22?= <fjuniorlista@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52791 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754554AbZG1P7X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 11:59:23 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVp4s-0005qh-3T
	for linux-nfs@vger.kernel.org; Wed, 29 Jul 2009 01:58:58 +1000
In-Reply-To: <4A6F0DCB.3090903@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46=E1bio Jr. wrote:
> Rob Gardner escreveu:
>  =20
>> F=E1bio Jr. wrote:
>>    =20
>>> Rob Gardner escreveu:
>>> =20
>>>      =20
>>>> F=E1bio Jr. wrote:
>>>>   =20
>>>>        =20
>>>>> Rob Gardner escreveu:
>>>>> =20
>>>>>     =20
>>>>>          =20
>>>>>> F=E1bio Jr. wrote:
>>>>>>          =20
>>>>>>            =20
>>>>>>> Hello all.
>>>>>>>
>>>>>>> Is there a way to export only some specific file extensions fro=
m=20
>>>>>>> a directory, like exporting only the files in /home/fabio with=20
>>>>>>> the .jpg extension?
>>>>>>>                =20
>>>>>>>              =20
>>>>>> You could do this pretty easily by exporting a 'fuse' filesystem=
=20
>>>>>> layered on top of your home directory.
>>>>>>
>>>>>> Rob Gardner
>>>>>> HP
>>>>>>
>>>>>>            =20
>>>>>>            =20
>>>>> Thanks Rob for the reply,
>>>>>
>>>>> This means that if I use this FUSE, I can export via NFS only the=
=20
>>>>> file extension that I need? let me explain my problem, not really=
 a=20
>>>>> problem, but a doubt.
>>>>>
>>>>> I have one storage that have my aplication files. This storage is=
=20
>>>>> mounted via NFS in my 3 aplication servers. Now I will put anothe=
r=20
>>>>> server, to serve only static files (jpg,png,css,js basically), an=
d=20
>>>>> though that maybe there is a way to export only these files from=20
>>>>> the storage. The problem is that these files are not organized in=
=20
>>>>> diferent folders.
>>>>>
>>>>> Maybe my first question doesn't explained my real necessity, but=20
>>>>> your answer will make me search a little more about FUSE.
>>>>>      =20
>>>>>          =20
>>>> I think your first question explained your need clearly. FUSE is a=
=20
>>>> filesystem layer that lets you filter requests through a user=20
>>>> program such as a python script. So, for instance, every time a=20
>>>> process opens a file, a function is called in your script, and you=
=20
>>>> can look at the name of the file being opened, and there decide=20
>>>> whether or not to allow the file to be opened. I think this would=20
>>>> solve your problem easily. Though all the storage is "exported",=20
>>>> only files with certain names (ie, *.jpg, etc) could be opened. Yo=
u=20
>>>> could also decide which files get enumerated with readdir, etc.
>>>>
>>>> Rob Gardner
>>>> HP
>>>>
>>>>
>>>>    =20
>>>>        =20
>>> Oh yes, I think I didn't understand you answer.. but now all became=
=20
>>> clear in my mind. I'm afraid that using this solution maybe cause a=
n=20
>>> increase on storage processor load, because for every request the=20
>>> script must be executed. I already have some issues with server=20
>>> availability, and perhaps the solution of a problem becomes the=20
>>> worsening of another.
>>>
>>> Still thanks for the reply and thanks for helping to clear my mind.
>>>      =20
>> It's a valid concern, but fuse does not "execute a script" for every=
=20
>> operation. The script is always running, sort of like a server for t=
he=20
>> pseudo-filesystem. Each requests causes a few lines in the script to=
=20
>> be executed. There is no process creation and dispatch for each=20
>> operation, only a process wakeup for each operation. It is=20
>> impressively lightweight and it's worth trying before dismissing it =
as=20
>> a resource drain.
>>
>>    =20
> Hmm.. that's interesting, but, how many requests this script can hand=
le?=20
> This can vary in diferent systems or configs, or even can be measured=
?
>  =20

OK now you're talking about throughput... that's different than=20
processor load. The fuser script is single threaded, I think, so it=20
probably won't scale too well.

You could go into the kernel and hack a filter into say, the nfs lookup=
=20
code, and cause lookup failures for files named '*.jpg' on certain=20
exports. That would scale, though would take quite a bit more work.



>> But anyway, here's another idea for you-- Export a new directory tha=
t=20
>> contains links to only those the files you want to export.
>>
>>    =20
> Unfortunately, even if I wanted to, it's not possible to do this in m=
y=20
> scenario, since I have aprox. 4 milion files only in jpeg format in=20
> different folders, not counting the other extensions. The major probl=
em=20
> was the planning phase, that not counted with so many files and not=20
> prepared the files organization to better performance. But for smalle=
rs=20
> systems, its a very good solution.

I guess you're in a better position to judge the suitability of a=20
proposed solution...  I can think of various reasons why creating links=
=20
might not be a good solution, but I don't see why having millions of=20
files presents any problem, as the process of creating links can be=20
automated rather easily.


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

