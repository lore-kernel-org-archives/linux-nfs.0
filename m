From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: Utils package testing
Date: Wed, 12 Jun 2002 08:22:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF3EB5EBA2.9E25EEF1-ON88256BD6.005374B3@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Tom McNeal <trmcneal@attbi.com>
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


I have run similar tests against a 4-way server running the 04/04/2002
snapshot of Trond's linux-2.4.18-NFS_ALL.dif patch and
nfs-utils-1-0-1-pre7.  The tests consisted of simultaneous runs of
bonnie++, fsx-linux, and different invocations of Connectathon2002.  There
were no apparent issues (although I'm not very familiar with bonnie++).

Tom, as for your question regarding client net statistics, IIRC these stats
were never collected.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                                    
                      Tom McNeal                                                                                                                    
                      <trmcneal@attbi.com>        To:       NFS maillist <nfs@lists.sourceforge.net>                                                
                      Sent by:                    cc:                                                                                               
                      nfs-admin@lists.sour        Subject:  [NFS] Utils package testing                                                             
                      ceforge.net                                                                                                                   
                                                                                                                                                    
                                                                                                                                                    
                      06/11/2002 09:33 AM                                                                                                           
                                                                                                                                                    
                                                                                                                                                    



Hi -

I've finished testing the latest utils package, nfs-utils-1-0-1-pre8,
both with udp and tcp mounts to the server, in both a 2.4.18 standard
and patched (Trond's NFS_ALL patch) environment, and it is ready to
go as far as I am concerned.  The difference between pre7 and pre8
was simply a warning message in exports.c, so any testing being
done on MP platforms (by those of you who have access to them)
need not be repeated.

A couple of questions have come up in my testing, which may have
to be addressed elsewhere, but are not related to the package:

 - Does locking take a much longer time in ext3 file systems,
   or in the patched environment?   In the patched kernel,
   exporting ext3, the connectathon lock tests seemed to take
   up to 10x as long, but that was over many hours, with a big
   load.  When run just once with the other connectathon tests,
   it didn't seem so different.

 - The client net statistics in /proc/net/rpc/nfs seems to remain
   at 0 regardless of the activity and regardless of the kernel.
   I'm going to start browsing through the kernel code to see
   if there is something obvious, but maybe someone knows about
   this already.  I didn't see anything in the mailing list.

Anyway, as soon as we hear results of MP testing, I'd say its
ready to ship.

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell)
------------------------------------------------------------

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -
http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs





_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
