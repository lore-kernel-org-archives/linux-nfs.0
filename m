From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 10:46:48 -0400
Message-ID: <46C06ED8.8030107@redhat.com>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKbCI-0003GL-FO
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 07:47:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKbCM-0001TY-C7
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 07:47:14 -0700
In-Reply-To: <Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Peter =C5strand wrote:
> On Mon, 13 Aug 2007, Peter Staubach wrote:
>
>   =

>>> This patch seems to overlap with linux-2.6-nfs-64-bit-inode-support.pat=
ch,
>>> which is included in RHEL5 kernels. Are these patches related, somehow?=
 The
>>> RHEL5 patch causes problems, as described at
>>> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D241348. =

>>>       =

>> They are related in that they modify similar areas in the NFS code.
>> However, this patch only modifies the NFS code and not the rest of
>> the file systems and areas in the kernel.
>>
>> My opinion on the referenced bugzilla is that things change and
>> it may be time to update applications and such to work in the
>> new world.  Applications which do not get modified, tend to work
>> less and less as time goes by because while the world changes
>> around them, they don't.
>>     =

>
> Sure, but to prevent customer unhappiness, it's much better to update the =

> applications in a certain distribution *before* changing the world around =

> them. I'm arguing that a typical customer would rather being able to run =

> OpenOffice than live in tomorrows world.
>
>   =


Without issues to drive and even to identify the broken applications,
they will never get fixed.

> Another reason why I'm not convinced of this patch is that I haven't hear=
d =

> any arguments why this is the time to break compatibility with =

> 32 bit non-LFS apps. Why not tomorrow, yesterday or 10 years ago? Why now=
? =

>
>   =


We have to start someplace, sometime.  In fact, we've already
started.  It is unfortunate that this particular aspect is only
now starting to become visible to application developers.  It
has been interesting to file systems developers for quite some
time.

>   =

>> I don't believe that this is the only cause which will keep those
>> applications from working completely.  With the addition of the
>> LFS thing, they will start to encounter more and more things that
>> they are not prepared to deal with.
>>     =

>
> Can you give an example? =

>
>   =


Files with large sizes?  We've had these for what, 10 to 12
years, and people have learned to deal with them.

> If we maintain "good-enough compatibility" with 32 bit non-LFS =

> applications now (proposed solution 1 or 2 in comment #6), we would still =

> have full 64 bit support for LFS and 64 bit applications, and as LFS and =

> 64 bit applications are becoming more and more common, the problem would =

> fade away.

There are many ways to get "good-enough compatibility".  One way
would be for customers with concerns or issues to only use file
system implementations which will only generate 32 bit inos.  The
majority of them still do.  Alternately, they could partition
their resources into chunks which would not require more then
32 bit inos for identification.  It is only the newer file systems,
seeking to take advantage of better technologies, both hardware
and software, which are required to use larger identifiers in order
to identify their files.

Supporting 64 bit inos in NFS does not mean that NFS will
automatically start generating 64 bit inos.  NFS is still dependent
upon the file system on the server.  The NFS will just pass through
whatever that the file system on the server presents to it.

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
