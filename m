From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: NFS client write performance issue ... thoughts?
Date: 08 Jan 2004 10:26:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrr7yajwao.fsf@lemming.engeast.baynetworks.com>
References: <16377.57599.284453.729190@lemming.engeast.baynetworks.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Aec3v-0003K5-NV
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:27:07 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aec3v-0002FQ-5u
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:27:07 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps0kp.nortelnetworks.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i08FQvq02117
	for <nfs@lists.sourceforge.net>; Thu, 8 Jan 2004 10:26:58 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i08FQuS15325
	for <nfs@lists.sourceforge.net>; Thu, 8 Jan 2004 10:26:56 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 1Aec3j-0004ua-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Jan 2004 10:26:55 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <16377.57599.284453.729190@lemming.engeast.baynetworks.com>
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

Hi all;

Here are some numbers which show the difference we're talking about.
Any comments anyone has are welcome; I'll be happy to discuss the
details of ClearCase NFS usage insofar as I understand it:

Note that the Linux build system is also using the same kernel
(2.4.18-27 from Red Hat).

> I did two identical small builds on my Linux desktop machine, wcary472,
> using NAS viewstore on scareac0, one with the view server running on
> Linux machine zcard0pf, and the other with the view server on Solaris
> machine zcars0z4.  I ran nfsstat on the view servers before and after
> the builds, after making sure that there was no (or very little) other
> activity on the machine that might have screwed up the numbers.  The raw
> nfsstat output is below.  Here's a summary of the important numbers:
> 
> View server on Linux 2.4.18-27 (zcard0pf):
> 
>    Build time: 35.75s user 31.68s system 33% cpu 3:21.02 total
>    RPC calls:     94922
>    RPC retrans:       0
>    NFS V3 WRITE:  63317
>    NFS V3 COMMIT: 28916
>    NFS V3 LOOKUP:  1067
>    NFS V3 READ:     458
>    NFS V3 GETATTR:  406
>    NFS V3 ACCESS      0
>    NFS V3 REMOVE      5
> 
> View server on Solaris 5.8 (zcars0z4)
> 
>    Build time:  35.50s user 32.09s system 46% cpu 2:26.36 total
>    NFS calls:      3785
>    RPC retrans:       0
>    NFS V3 WRITE:    612
>    NFS V3 COMMIT:     7
>    NFS V3 LOOKUP:  1986
>    NFS V3 READ:       0
>    NFS V3 GETATTR:  532
>    NFS V3 ACCESS    291
>    NFS V3 REMOVE    291
> 
> NOTES:
> 
>  - Viewstore on Linux was mounted using UDP with rsize=wsize=4096
>    Viewstore on Solaris was mounted using TCP with rsize=wsize=32768
>    I would have changed these to be the same except that that would
>    have required root access on one or the other view server machine,
>    which I didn't have.  Other experiments have shown that Linux does
>    fewer WRITES with TCP/32K mounts, but it's still considerably worse
>    than Solaris.  As I mentioned, I don't know why increasing [rw]size
>    and/or switching to TCP improves matters on Linux.
> 
>  - I don't know where those NFS REMOVEs are coming from, but I vaguely
>    remember seeing the view server doing some weird things when I was
>    able to strace it.  It does bother me that there was a big difference
>    in the number of REMOVEs done from Solaris vs. Linux; that might imply
>    that the there are important implementation differences between Linux
>    and Solaris.
> 
> So there were nearly 100K WRITES+COMMITS on Linux, but only a few hundred
> on Solaris.  I didn't doublecheck it this time, but I know from past
> experience that most of the NFS I/O from the view server would have
> been against files in the view database directory, which looks like this
> after the build has finished (both view databases are similar in size):
> 
>   (zcars0z4) ~>> ls -l .../db
>   -rw-r--r--   1 dgraham  fwptools   278528 Jan  8 05:30 view_db.d01
>   -rw-r--r--   1 dgraham  fwptools   106496 Jan  8 05:30 view_db.d02
>   -rw-rw-r--   1 dgraham  fwptools     7143 Jun 13  2001 view_db.dbd
>   -rw-r--r--   1 dgraham  fwptools   114688 Jan  8 05:30 view_db.k01
>   -r--r--r--   1 dgraham  fwptools        3 Jun 13  2001 view_db_schema_version
>   -rw-r--r--   1 dgraham  fwptools    17519 Jan  8 05:30 vista.log
>   -rw-r--r--   1 dgraham  fwptools     5146 Jan  8 05:30 vista.taf

-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
