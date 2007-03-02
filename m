From: Eli Stair <estair@ilm.com>
Subject: Re: Linux client cache corruption,
	system call returning  incorrectly
Date: Fri, 02 Mar 2007 13:58:17 -0800
Message-ID: <45E89DF9.9000303@ilm.com>
References: <45E796B7.9010707@ilm.com>
	<EXNANE01XvpFVjCRGry00000034@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HNFln-0003xL-Vo
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 13:58:32 -0800
Received: from gateway01.lucasfilm.com ([63.82.98.221])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HNFln-0006bX-UJ
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 13:58:34 -0800
In-Reply-To: <EXNANE01XvpFVjCRGry00000034@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Still working on getting more useful debug output (MANY-layered 
application run through a batch scheduler) from the system calls 
themselves.  It doesn't look like the errors occur on stat() after all, 
but open().

The problem being an ENOENT that should NOT be occuring, as the file 
exists and is perfectly readable by other clients at the time of the 
open, as confirmed by the pcaps and other sequential successes.  This is 
what I am considering real breakage of the client.  Note that I've 
confirmed that this does not occur when accessing the same files over a 
local block device, only NFS.  No locks are occuring, and the file is 
opened read-only, so there should be no contention or reason that I can see.

Here's an strace of operations across several clients opening the file 
at the same time, showing one succeed and one fail.

> deathstar1071:/strace # cat RIB_OPENS.txt  | grep  "geom.55.rib" | grep -v stat
> shot1.estair.test3strace.pid.11296:open("/path/file/geom.55.rib", O_RDONLY) = -1 ENOENT (No such file or directory)
> shot1.estair.test3strace.pid.12115:open("/path/file/geom.55.rib", O_RDONLY) = 4

> deathstar1071:/strace # ls -la path/file/geom.55.rib
> -rw-rw----  1 uid gid 406206 Feb 22 11:58 /path/file/geom.55.rib
> 

If this were a ulimit issue for the process, it would receive an ENFILE 
not the ENOENT right?  It's looking like there's a disconnect in-kernel 
when system calls are occuring over NFS.  Strangely, I left a test prog 
running over night just doing an open(), stat(), readc(), then close() 
of these same files for 5000+ iterations without reproducing the issue. 
  So it doesn't appear to be a library issue since the call itself is 
returning improperly, but some usage/access pattern (above simple ops) 
is triggering it.

I never found what update/patch fixed the issue, but the 2.6.15 fseek() 
bug I tracked down similarly occured over NFS only.  When performing a 
write into a file, then a seek and write at the head, 10%+ of the time a 
seek to EOF would return to the wrong byte offset.  This is seeming as 
fatal but more obscure.


/eli





Talpey, Thomas wrote:
> Do you mean ENFILE? If so, what's your process's file descriptor limit
> (ulimit -n)? Since stat(2) doesn't open anything, in theory it shouldn't
> return this. fstat(2) takes a file descriptor but again, doesn't open
> anything.
> 
> I wouldn't recommend using rpcdebug, since this is probably a local
> issue. Rpcdebug will show over-the-wire stuff, mostly. Strace will
> probably be the best tool.
> 
> Tom.
> 
> At 10:15 PM 3/1/2007, Eli Stair wrote:
>  >
>  >I'm having a serious client cache issue on recent kernels.  On 2.6.18
>  >and 2.6.20 (but /not/ 2.6.15.4) clients I'm seeing periodic file GETATTR
>  >or ACCESS calls that return fine from the server pass an ENOFILE up to
>  >the application.  It occurs against all NFS servers I've tested (2.6.18
>  >knfsd, OnTap 10.0.1, SpinOS 2.5.5p8).
>  >
>  >The triggering usage stage is repeated stat'ing of a several hundred
>  >files that are opened read-only (but not close() or open()'ing it again)
>  >during runtime.  I have been unable to duplicate the usage into a
>  >bug-triggering testcase yet, but it is very easily triggered by an
>  >internal app.  Mounting the NFS filesystems with 'nocto' appears to
>  >mitigate the issue by about 50%, but does not completely get rid of it.
>  >  Also, using 2.6.20+ Trond's NFS_ALL patches and this one you supplied
>  >also slow the rate of errors, but not completely.
>  >
>  >I'm rigging the application with an strace harness so I can track down
>  >specifically what ops are failing in production.  I can confirm that
>  >those errors I have witnessed under debug are NOT failing due to an NFS
>  >call returning where access is denied, or on an open(), it appears to be
>  >stat() of the file (usually several dozen or hundreds in sequence) that
>  >return ENOFILE, though the call should return sucess.
>  >
>  >Any tips on using rpcdebug effectively?  I'm getting tremendous levels
>  >of info output with '-m nfs -s all', too much to parse well.
>  >
>  >I'll update with some more hard data as I get further along, but want to
>  >see if a) anyone else has noticed this and working on a fix, and b) if
>  >there are any suggestions on getting more useful data than what I'm
>  >working towards.
>  >
>  >Reverting to 2.6.15.4 (which doesn't exhibit this particular bug) isn't
>  >a direct solution even temporarily, as that has a nasty NFS fseek bug
>  >(seek to EOF goes to wrong offset).
>  >
>  >Cheers,
>  >
>  >
>  >/eli
> 
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
