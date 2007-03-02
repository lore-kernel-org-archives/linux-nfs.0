From: Eli Stair <estair@ilm.com>
Subject: Linux client cache corruption,
	system call returning incorrectly
Date: Thu, 01 Mar 2007 19:15:03 -0800
Message-ID: <45E796B7.9010707@ilm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMyEl-0003au-90
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 19:15:15 -0800
Received: from gateway01.lucasfilm.com ([63.82.98.221])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMyEm-0007zu-80
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 19:15:17 -0800
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


I'm having a serious client cache issue on recent kernels.  On 2.6.18 
and 2.6.20 (but /not/ 2.6.15.4) clients I'm seeing periodic file GETATTR 
or ACCESS calls that return fine from the server pass an ENOFILE up to 
the application.  It occurs against all NFS servers I've tested (2.6.18 
knfsd, OnTap 10.0.1, SpinOS 2.5.5p8).

The triggering usage stage is repeated stat'ing of a several hundred 
files that are opened read-only (but not close() or open()'ing it again) 
during runtime.  I have been unable to duplicate the usage into a 
bug-triggering testcase yet, but it is very easily triggered by an 
internal app.  Mounting the NFS filesystems with 'nocto' appears to 
mitigate the issue by about 50%, but does not completely get rid of it. 
  Also, using 2.6.20+ Trond's NFS_ALL patches and this one you supplied 
also slow the rate of errors, but not completely.

I'm rigging the application with an strace harness so I can track down 
specifically what ops are failing in production.  I can confirm that 
those errors I have witnessed under debug are NOT failing due to an NFS 
call returning where access is denied, or on an open(), it appears to be 
stat() of the file (usually several dozen or hundreds in sequence) that 
return ENOFILE, though the call should return sucess.

Any tips on using rpcdebug effectively?  I'm getting tremendous levels 
of info output with '-m nfs -s all', too much to parse well.

I'll update with some more hard data as I get further along, but want to 
see if a) anyone else has noticed this and working on a fix, and b) if 
there are any suggestions on getting more useful data than what I'm 
working towards.

Reverting to 2.6.15.4 (which doesn't exhibit this particular bug) isn't 
a direct solution even temporarily, as that has a nasty NFS fseek bug 
(seek to EOF goes to wrong offset).

Cheers,


/eli


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
