From: Dan Yocum <yocum@fnal.gov>
Subject: Re: Null characters in files on NFS mounted volume....
Date: Tue, 14 May 2002 09:41:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CE12223.65042278@fnal.gov>
References: <3CDFCE9F.2BE050D5@fnal.gov>
 <15584.8750.59660.285982@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heffalump.fnal.gov ([131.225.9.20] helo=fnal.gov)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177dUi-0007oS-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 07:41:40 -0700
Received: from fnal.gov ([131.225.7.82]) by smtp.fnal.gov (PMDF V6.0-24 #37519)
 with ESMTP id <0GW3003IIVHFEL@smtp.fnal.gov> for nfs@lists.sourceforge.net;
 Tue, 14 May 2002 09:41:39 -0500 (CDT)
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

Neil Brown wrote:
> 
> On Monday May 13, yocum@fnal.gov wrote:
> > Hi all,
> >
> > I've got a "New and Exciting" <tm> bug using 2.4.18 with Trond's client
> > patches (sans the rpc_tweaks dif), but I'm not sure it's a client side
> > problem.
> >
> > This is an intermitent problem:  When attempting to read a file (any file)
> > on an NFS mounted volume, there appear to be "holes" in the file filled with
> > ASCII NULL characters.  Reading the file on the local machines shows no such
> > holes, and other NFS clients don't see the holes, either.  A simple
> > umount/remount solves the problem.
> 
> I remembers long ago some referred to NFS as
>    Nulls Frequently Substituted
> because they were experiencing exactly this sort of thing, and it
> wasn't on Linux at all.

Ha!  :-)

I did find a similar occurence while googling
(http://www.geocrawler.com/archives/3/4/1998/11/0/59164/), reported back in
'98 on LinuxPPC, that produced similar results, but since this happened 3
times on the same day to 3 different machines, I thought I'd report it.


> 
> You wouldn't be using 'soft' mounts would you?


yup, automounted with these options:  

-rw,grpid,soft,intr,quota,nodev,nosuid,timeo=10,retrans=3


I suppose they could be hard....  I'll think about that.

Cheers,
Dan



-- 
Dan Yocum
Sloan Digital Sky Survey, Fermilab  630.840.6509
yocum@fnal.gov, http://www.sdss.org
SDSS.  Mapping the Universe.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
