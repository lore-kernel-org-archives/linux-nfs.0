From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: RE: Rename window
Date: Fri, 11 Nov 2005 15:28:04 -0000
Message-ID: <9E621559095AA746B22B21CD4FAF99A55735BC@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eaap8-0008HM-GF
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 07:28:18 -0800
Received: from smtp2.dataconnection.com ([192.91.191.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eaap8-0006dV-15
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 07:28:18 -0800
To: "Peter Staubach" <staubach@redhat.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Thanks for your replies.  We're getting round this by ensuring that we
don't rename to the same name - we can put something machine-specific in
the destination filename fairly easily.

However I should probably have said that our test app suggests this
doesn't occur with Solaris NFS clients, which might influence people's
opinion on whether it should be fixed.

Regards,

Edward.

-----Original Message-----
From: Peter Staubach [mailto:staubach@redhat.com]=20
Sent: 11 November 2005 15:25
To: Trond Myklebust
Cc: Edward Hibbert; nfs@lists.sourceforge.net
Subject: Re: [NFS] Rename window

Trond Myklebust wrote:

>On Fri, 2005-11-11 at 09:58 -0500, Peter Staubach wrote:
> =20
>
>>Trond Myklebust wrote:
>>
>>   =20
>>
>>>On Fri, 2005-11-11 at 11:42 +0000, Edward Hibbert wrote:
>>>=20
>>>
>>>     =20
>>>
>>>>I have noticed a atomicity problem with the handling of rename by=20
>>>>the Linux NFS client, and just wanted to check if this is something=20
>>>>that we just have to work-around, or is there some other solution.
>>>>
>>>>The problem arises when two different machines issue a file rename=20
>>>>which is identical.
>>>>
>>>>E.g. rename oldname newname
>>>>
>>>>You would expect that one machine would be successful, and the other
>>>>would fail.    However, the NFS client seems to be issuing 3 NFS
>>>>operations to perform the rename
>>>>     * LOOKUP oldname=20
>>>>     * LOOKUP newname=20
>>>>     * RENAME oldname newname
>>>>There is a timing window where both LOOKUPs can succeed (if the
other
>>>>machine does the rename at the right time).   In this case, the
Linux
>>>>NFS client does not issue the final NFS RENAME operation - BUT still

>>>>returns success to the caller.
>>>>
>>>>Thus both machines have succeeded in renaming the file.
>>>>
>>>>You might argue that since they are performing the same operation=20
>>>>that it is OK for both to succeed, but I have an application that=20
>>>>depends on the atomicity of the operation, as it uses the filename=20
>>>>to hold a counter, and rename to assign a unique counter to a
process.
>>>>  =20
>>>>
>>>>       =20
>>>>
>>>This is another of those cases where the VFS has optimised for local=20
>>>filesystem behaviour, and where fixing this problem would require=20
>>>significant VFS changes.
>>>You'd basically have to add a new lookup intent for the RENAME=20
>>>function in order to tell the NFS layer that it can ignore the lookup
requests.
>>>We probably will get round to doing that sometime, but it is not one=20
>>>of the most pressing bugs on my list.
>>>
>>>In the meantime, I'd suggest just not relying on this level of=20
>>>atomicity (there are in any case situations where this is always=20
>>>impossible - for instance in sillyrename() situations).
>>>
>>>     =20
>>>
>>It is true that rename(2) is supposed to be atomic.
>>
>>It is also true that this is a problem in an optimization in the file=20
>>system independent layer in the current Linux.  There is a check which

>>compares the "from" inode and the "to" inode and, if they are the=20
>>same, just returns no error, ie. success.  NFS does need at least the=20
>>lookup on the "to" name so that it can handle the rename to an open
file case.
>>
>>Couldn't this be (fairly) easily handled by making the short circuit=20
>>check in vfs_rename() conditional and not use it for NFS mounted file=20
>>systems and perhaps others?
>>   =20
>>
>
>That causes weird behaviour to pop up in other places. One classic is=20
>the rename of an open file onto a hard link of itself, where unless=20
>someone (either NFS or the VFS) tests those inodes for equality, NFS=20
>will end up sillyrenaming the hard link, then renaming the open file in

>complete violation of POSIX.
>

I suppose that a check could be added for the hard link count, but yuck,
that is a nasty situation.  Oh well, good point...

       ps


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
