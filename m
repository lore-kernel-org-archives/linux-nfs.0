From: Peter Staubach <staubach@redhat.com>
Subject: Re: Rename window
Date: Fri, 11 Nov 2005 09:58:02 -0500
Message-ID: <4374B17A.7030806@redhat.com>
References: <9E621559095AA746B22B21CD4FAF99A557356D@EDINMAIL1.ad.datcon.co.uk> <1131716316.8805.16.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Edward Hibbert <Edward.Hibbert@dataconnection.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaaM8-0006ke-ER
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 06:58:20 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EaaM7-0003DP-A8
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 06:58:20 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1131716316.8805.16.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>On Fri, 2005-11-11 at 11:42 +0000, Edward Hibbert wrote:
>  
>
>>I have noticed a atomicity problem with the handling of rename by the
>>Linux NFS client, and just wanted to check if this is something that
>>we just have to work-around, or is there some other solution.
>> 
>>The problem arises when two different machines issue a file rename
>>which is identical.
>> 
>>E.g. rename oldname newname
>> 
>>You would expect that one machine would be successful, and the other
>>would fail.    However, the NFS client seems to be issuing 3 NFS
>>operations to perform the rename
>>      * LOOKUP oldname 
>>      * LOOKUP newname 
>>      * RENAME oldname newname
>>There is a timing window where both LOOKUPs can succeed (if the other
>>machine does the rename at the right time).   In this case, the Linux
>>NFS client does not issue the final NFS RENAME operation - BUT still
>>returns success to the caller.
>> 
>>Thus both machines have succeeded in renaming the file.
>> 
>>You might argue that since they are performing the same operation that
>>it is OK for both to succeed, but I have an application that depends
>>on the atomicity of the operation, as it uses the filename to hold a
>>counter, and rename to assign a unique counter to a process.
>>    
>>
>
>This is another of those cases where the VFS has optimised for local
>filesystem behaviour, and where fixing this problem would require
>significant VFS changes.
>You'd basically have to add a new lookup intent for the RENAME function
>in order to tell the NFS layer that it can ignore the lookup requests.
>We probably will get round to doing that sometime, but it is not one of
>the most pressing bugs on my list.
>
>In the meantime, I'd suggest just not relying on this level of atomicity
>(there are in any case situations where this is always impossible - for
>instance in sillyrename() situations).
>

It is true that rename(2) is supposed to be atomic.

It is also true that this is a problem in an optimization in the file system
independent layer in the current Linux.  There is a check which compares the
"from" inode and the "to" inode and, if they are the same, just returns no
error, ie. success.  NFS does need at least the lookup on the "to" name so
that it can handle the rename to an open file case.

Couldn't this be (fairly) easily handled by making the short circuit check
in vfs_rename() conditional and not use it for NFS mounted file systems
and perhaps others?

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
