From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: nfs support of FAT file systems
Date: Tue, 11 Mar 2003 20:39:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E6EB9E4.9000504@attbi.com>
References: <B98C57C204171A46BDFA264D6008EE1816C64A@exchange1.miltope.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc01.attbi.com ([204.127.202.61])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sxzf-0002gX-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 20:37:31 -0800
To: Eno Compton <Eno.Compton@Miltope.com>,
	NFS maillist <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi -

Here is a more complete answer from Neil Brown, covering the various FAT
file systems.  I will be putting a discussion of this into the FAQ, since I 
think its
an important issue to a lot of folks:

    NFS access to FAT filesystems works for simple cases, starting with the
    early 2.4 kernels, but if used extensively can cause grief.

    FAT file systems can be exported, but only those operations supported by
    that file system will be honoured.  *Note* Operations such as "chown",
    "link", and "symlink" are not supported by these file systems, and will fail.
     Read/write/create etc., should be fine as long as the files remain relatively
     unchanged.  The FAT filesystem layout does not contain enough
     information to create a lasting identity needed for NFS to create persistent
     filehandles.  For example,  If you take a file, rename it to another 
directory,
    trunctate it, and write new data to it, there is nothing stored in the 
filesystem
    that can be used to show that the resulting file is, in any sense, the 
"same" as
    the original file, and there is no way to find the new file given any 
details about
    the original file.  Therefore,  the Linux NFS server cannot guarantee that
    once you have opened a file, you can continue to have access to that file.
    If the file is modified in the ways given above, NFS may be unable to locate
    or identify the file correctly, and so may return ESTALE errors.  This may
    happen  if the fileserver is rebooted, or if the fileserver is under heavy 
memory
    pressure.  The only fix which might be applied would require file handle 
changes,
    and would  not completely solve the problem, and would be a lot of work, so it
    doesn't look likely at all.


I hope this helps.

Tom


Eno Compton wrote:

> I thank you, Tom, for your trouble.
> Eno
> 
>  -----Original Message-----
> From: 	trmcneal@attbi.com [mailto:trmcneal@attbi.com] 
> Sent:	Monday, March 10, 2003 11:43 AM
> To:	Eno Compton
> Subject:	Re: nfs??
> 
> I believe that is correct.  Linux will certainly allow fat32 mounts, but
> exporting one is a different matter. I'll check to make sure.
> 
> Regards -
> 
> Tom
> 
> --
> Tom McNeal
> (650)906-0761(cell)
> (650)964-8459(fax)
> 
>>Don't know if it's proper to contact you directly. Hope so. Can't find an
>>answer.
>>I think nfs will not export a fat32 partition under linux. Is that correct?
>
>>Eno Compton
>>
> 

-- 
Tom McNeal
(650)906-0761(cell)
(650)964-8459(fax)
Email: trmcneal@attbi.com



-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
