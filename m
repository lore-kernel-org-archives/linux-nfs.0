From: =?ISO-8859-1?Q?J=F6rgen_Karlsson?= <publius@chello.se>
Subject: Re: knsfd - files don't sync to disk
Date: Fri, 17 May 2002 19:18:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CE53B56.8040303@chello.se>
References: <3CE40BF7.1090605@chello.se> <15588.61537.552697.595814@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp2.chello.se ([193.150.195.11])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178lG2-0004co-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 10:11:10 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

We are using NFSv2.

We have found a temporary workaround by reducing the number of nfs threads
to 1. 

We have a 30 processor cluster that gave zero size files everytime we made
a backup. By reducing the number of threads from 8 to 1 we were able to make
25 backups without any problem. Switching back to 8 threads we immediately
got the corrupted files back.

Maybe some down() and up() are missing.......

If you think the the patch may fix it for v2 as well as v3 we can try the
patch next week.

Can running with only one thread cause any performance problems (with
sync the bottleneck probably is disk io....)?

/Jorgen Karlsson

Neil Brown wrote:

>Are you using NFSv3?
>
>Does this patch:
>http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.19-pre5/patch-I-NfsdVfsTidyup
>
>make a difference?
>
>NeilBrown
>
>On Thursday May 16, jorgen.karlsson@chello.se wrote:
>
>>Hi,
>>
>>We have a serious problem with knfsd and kernel 2.4.17.
>>
>>When doing a database backup in our linux cluster we have noticed that
>>a few files are not written to disk properly. The files have zero
>>file size when checked with the 'ls' command
>>
>>Several thousands of files are written to the nfs server during a
>>short period of time.  Average file size is 300-400 bytes.
>>
>>We have noticed that usually 1-2 out of 3000 files will have their sizes
>>truncated to 0.
>>
>>File  system is exported with (rw,sync)
>>
>>The disk filesystem is ext2.
>>
>>E.g. this is what is happening:
>>          - client writes 272 bytes to the server
>>          - mm/file.c:generic_file_write() returns 272 bytes written
>>          - fs/nfsd/vfs.c:nfs_write() increments nfsdstats.io_write +=272
>>             and returns that the write was sucessful.
>>          - knfsd returns to client that 272 bytes was written.
>>          - when checking with 'ls' command on server the file size is zero.
>>
>>Apparently the nfs server lies to the client and the files are not
>>properly synced/written to disk.
>>
>>Setting no_wdelay makes no difference.
>>
>>When running with async set (or sync removed) the problem
>>disappears (no files have their sizes truncated to zero).
>>
>>The nfs server is a PIII-700/ 1GB RAM
>>
>>Any ideas what is going on ?
>>
>
>_______________________________________________________________
>
>Have big pipes? SourceForge.net is looking for download mirrors. We supply
>the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>




_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
