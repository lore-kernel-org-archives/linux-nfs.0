From: Dan Yocum <yocum@fnal.gov>
Subject: Re: Null characters in files on NFS mounted volume....
Date: Fri, 24 May 2002 11:44:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CEE6DEB.B6153F2D@fnal.gov>
References: <200205141734.g4EHYnT32724@buggy.badula.org>
 <3CE15F70.7C8B8433@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heffalump.fnal.gov ([131.225.9.20] helo=fnal.gov)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BIB3-0000Hf-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 09:44:29 -0700
Received: from fnal.gov ([131.225.7.82]) by smtp.fnal.gov (PMDF V6.0-24 #37519)
 with ESMTP id <0GWM0005NJU4JC@smtp.fnal.gov> for nfs@lists.sourceforge.net;
 Fri, 24 May 2002 11:44:28 -0500 (CDT)
To: nfs@lists.sourceforge.net
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

Just an update - the null characters problem hasn't cropped up again, and I
haven't done anything to "fix" the problem, either - the mounts are still
'soft', etc.

I'm about ready to declare it a non-reproducable network error and nothing
to do with NFS, but if it turns up again, I'll let you know.

Thanks,
Dan

Ion Badulescu wrote:
> 
> On Tue, 14 May 2002 09:41:39 -0500, Dan Yocum <yocum@fnal.gov> wrote:
> >> > This is an intermitent problem:  When attempting to read a file (any file)
> >> > on an NFS mounted volume, there appear to be "holes" in the file filled with
> >> > ASCII NULL characters.  Reading the file on the local machines shows no such
> >> > holes, and other NFS clients don't see the holes, either.  A simple
> >> > umount/remount solves the problem.
> >>
> > Neil Brown wrote:
> >> You wouldn't be using 'soft' mounts would you?
> >
> > yup, automounted with these options:
> >
> > -rw,grpid,soft,intr,quota,nodev,nosuid,timeo=10,retrans=3
> 
> In that case let me ask you this: is your application checking the return
> code of the read()? or are you using mmap() instead of read()?
> 
> If read() returns zero-filled buffers without signalling an errors, it's
> a problem in the NFS client. That is, assumming it's not some bad interaction
> between XFS and the NFS server -- so try to clear up that possibility
> by mounting with the hard option.
> 
> If you're using mmap(), then I don't even know how the system should tell
> you about the problem... I suppose it would be sending a SIGSEGV or SIGBUS
> signal, since it's ultimately a failing page fault, but I haven't tested it.
> 
> > I suppose they could be hard....  I'll think about that.
> 
> Yes, they _should_ be hard if you care about your data integrity.
> 
> But that shouldn't stop us from fixing bugs in the 'soft' model, if they
> exist... which is why I'm asking you all these details. :-)
> 
> Ion
> 
> --
>   It is better to keep your mouth shut and be thought a fool,
>             than to open it and remove all doubt.





-- 
Dan Yocum
Sloan Digital Sky Survey, Fermilab  630.840.6509
yocum@fnal.gov, http://www.sdss.org
SDSS.  Mapping the Universe.

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
