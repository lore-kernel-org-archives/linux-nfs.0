From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with statd and lockd
Date: Sun, 6 Apr 2003 14:16:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16016.6804.336490.539227@charged.uio.no>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
	<200304051545.43063.bernd-schubert@web.de>
	<shs7ka9c957.fsf@charged.uio.no>
	<200304051831.09682.bernd-schubert@web.de>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19294V-0003jV-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Apr 2003 05:16:27 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200304051831.09682.bernd-schubert@web.de>
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

>>>>> " " == Bernd Schubert <bernd-schubert@web.de> writes:

     > statd: server localhost not responding, timed out
     > nsm_mon_unmon: rpc failed, status=-5 lockd: cannot monitor
     > <server IP> lockd: failed to monitor <server IP>

     > So on our systems not the server, but the clients are reporting
     > those messages.

That is normal: lockd is a strange being. It has to run as a server on
both the NFS client and the NFS server.

     > Apr 5 15:28:16 maxwell kernel: statd: server localhost not
     > responding, timed out Apr 5 15:28:16 maxwell kernel: lockd:
     > cannot monitor <server IP> Apr 5 15:28:16 maxwell kernel:
     > lockd: failed to monitor <server IP>

     > What other messages do you expect ?

If secure-statd was the cause of the problem, I would expect
additional messages of the form

  "Call to statd from non-local host blah"

or

  "Attempt to register callback to 1000xy/z"

or

  "Attempt to register host blah (not a dotted quad)"

     > As soon as I stop the debian-statd and start the new statd
     > (that has secure-statd disabled), those messages disappear.
     > Furthermore, some programs as e.g. KDE have some problems to
     > run when those messages appear (our home directory is served by
     > this server).

     > What problems can be caused by a statd without the secure
     > option ?

People could use your statd to make arbitrary RPC calls.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
