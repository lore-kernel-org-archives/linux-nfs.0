From: Ion Badulescu <ionut@cs.columbia.edu>
Subject: Re: Null characters in files on NFS mounted volume....
Date: Tue, 14 May 2002 13:34:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205141734.g4EHYnT32724@buggy.badula.org>
References: <3CE12223.65042278@fnal.gov>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bgp401130bgs.jersyc01.nj.comcast.net ([68.36.96.125] helo=buggy.badula.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177gCN-0006QO-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 10:34:55 -0700
To: Dan Yocum <yocum@fnal.gov>
In-Reply-To: <3CE12223.65042278@fnal.gov>
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

On Tue, 14 May 2002 09:41:39 -0500, Dan Yocum <yocum@fnal.gov> wrote:
>> > This is an intermitent problem:  When attempting to read a file (any file)
>> > on an NFS mounted volume, there appear to be "holes" in the file filled with
>> > ASCII NULL characters.  Reading the file on the local machines shows no such
>> > holes, and other NFS clients don't see the holes, either.  A simple
>> > umount/remount solves the problem.
>> 
> Neil Brown wrote:
>> You wouldn't be using 'soft' mounts would you?
> 
> yup, automounted with these options:  
> 
> -rw,grpid,soft,intr,quota,nodev,nosuid,timeo=10,retrans=3

In that case let me ask you this: is your application checking the return
code of the read()? or are you using mmap() instead of read()?

If read() returns zero-filled buffers without signalling an errors, it's
a problem in the NFS client. That is, assumming it's not some bad interaction
between XFS and the NFS server -- so try to clear up that possibility
by mounting with the hard option.

If you're using mmap(), then I don't even know how the system should tell
you about the problem... I suppose it would be sending a SIGSEGV or SIGBUS
signal, since it's ultimately a failing page fault, but I haven't tested it.

> I suppose they could be hard....  I'll think about that.

Yes, they _should_ be hard if you care about your data integrity.

But that shouldn't stop us from fixing bugs in the 'soft' model, if they
exist... which is why I'm asking you all these details. :-)

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
