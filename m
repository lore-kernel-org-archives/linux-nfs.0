From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: v3/tcp mounts occasionally hang for 10+ minutes
Date: 02 Apr 2002 10:36:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshemuijkd.fsf@charged.uio.no>
References: <5.0.2.1.0.20020401235131.0285bb00@pop.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16sJm2-0001BY-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Apr 2002 00:36:14 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <5.0.2.1.0.20020401235131.0285bb00@pop.sfrn.dnai.com>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > Linux client running 2.4.17+NFS_ALL patch set mounting a netapp
     > server (via switched 100FDx ethernet) with the following mount
     > opts:

     > rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr,hard

     > Works great, but occasionally (every few days) the mount hangs,
     > for about 10 minutes each time. I am not exactly sure what
     > causes the hung mounts but at times it has seemed to correlate
     > with the machine running very low on virtual memory and the
     > kernel interceding to kill processes. Other times this has not
     > seemed to be the case. Either way, it doesn't seem like
     > something which should be happening.

If the OOM killer is signalling the rpciod process, then that could
indeed cause the sort of problem you are describing.
If so, please could you look into the circumstances that are causing
the OOM killer to do this. Normally rpciod should never be much of a
memory hog.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
