From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: NFS client write performance issue ... thoughts?
Date: 12 Jan 2004 16:37:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrbrp8j1bq.fsf@lemming.engeast.baynetworks.com>
References: <32997.141.211.133.197.1073683824.squirrel@webmail.uio.no>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Ag9kS-0008La-Ho
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 13:37:24 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ag9kS-0002ZF-24
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 13:37:24 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps0kp.nortelnetworks.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i0CLbFA11618
	for <nfs@lists.sourceforge.net>; Mon, 12 Jan 2004 16:37:16 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i0CLbDK14215
	for <nfs@lists.sourceforge.net>; Mon, 12 Jan 2004 16:37:14 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 1Ag9kH-0007bm-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Jan 2004 16:37:13 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <32997.141.211.133.197.1073683824.squirrel@webmail.uio.no>
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

Thanks Trond.

We tried out your patch and it did really make a difference in terms of
both the nfsstat numbers (or, Ethereal in this case) AND the performance
the user sees, at least from a ClearCase perspective (gnurr.diff is with
your patch):

> This time, I used my desktop box (running 2.4.18-27.7.x + gnurr.diff)
> as view server, while running the small build on a different Linux box.
> I captured NFS traffic with Ethereal, so as to rule out any possible
> accounting errors in nfsstat.  Here's what the numbers look like:
> 
>            nopatch  gnurr.dif    gnurr.diff     Solaris
>             UDP/4K     UDP/4K       UDP/32K     TCP/32K
>            -------  ---------    ----------     -------
>     WRITE    65017       1298           538         612
>     COMMIT   29268        994           882           7
>     LOOKUP    1082       1020          1016        1986
>     GETATTR    548        490           404         532
>     READ       480         75            89           0
>     FSSTAT      60          3             3          60
>     FSINFO      60          3             3           0
>     REMOVE      19         15             8         291
>     ACCESS       0          0             0         291
>     NULL        10          6             5           0
>     SETATTR      4          2             3           2
>     RENAME       4          2             3           2
>     CREATE       4          2             3           2
>     ======   =====       ====          ====        ====
>     Total    96556       3910          2957        3785
> 
>     CPU        85s        85s           85s         85s
>     Elapsed   202s       121s          121s        139s
> 
> Bytes read: 1.97MB      0.3MB         0.7MB          ??
> Bytes writ: 90.3MB      5.2MB         4.9MB          ??
> 
> The Solaris numbers are from the same capture I did a few days ago.
> For the build times, all builds were done on a machine in our Linux
> pool (which was not patched), using my desktop in various
> configurations as view server.  For the Solaris view server, I used a
> Sun Ultra-80 running Solaris 8.  CPU use was that used by the build
> itself, not the view server, so we'd expect it to be constant.
> 
> So Linux with the gnurr.dif patch stacks up pretty well against Solaris.
> Note that there are no numbers here for Linux with TCP mounts.  That's
> because I was analyzing the data with ethereal, and it often can't
> find the RPC boundaries properly when TCP is in use, so the numbers
> are meaningless.
> 
> One noticable difference between Linux and Solaris is that Linux
> generates a lot more COMMITS than Solaris.

However, then we discovered something concerning, so we are not using
the patch as-is right now, at least pending further investigation:

> Oops.  With this patch applied, I didn't see a problem when using
> my desktop as view server, but when I use it to do builds on, I'm
> occasionally seeing the following:
> 
>   ldsimpc: final link failed: Message too long
> 
> Ldsimpc is the GNU linker built as a cross-linker for VxSim (ie: for
> MinGW).  The linker is getting EMSGSIZE somehow, and at this point, I
> can only guess that it's getting it on a call to write().  Probably NFS
> is trying to write an overly large UDP packet to the server.  This is
> with UDP mounts and rsize=wsize=4KB.  Write failures are a little scary,
> so I think I'm going to back out this patch for now.

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
