From: "Bryan J. Smith" <b.j.smith@ieee.org>
Subject: Newer RedHat kernels and autofs/NFS ...
Date: 12 Apr 2002 14:32:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1018636370.2377.106.camel@bitman.oviedo.smithconcepts.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Anyone of you out there running RedHat 7.2 and newer RedHat kernels
(2.4.17/2.4.18) off of Rawhide (or even stock kernels)?

I've been having some issues with 2.4.17 and 2.4.18 kernels from
Rawhide, although rebuilt from source, and NFS.  I cannot pin-point if
the issue is autofs (or autofs4 as well via modules.conf), nfs-utils,
the kernel's NFS implementation or other.  Going back to 2.4.9 kernels
solves the issues everytime.

It's obvious that I'm having client "hangs" until I give the NFS service
on the server a restart.  NFS locking issues are rampant too.  I'm
having this issue regardless of whether or not the NFS server is RedHat
6.2 / kernel 2.2.x or RedHat 7.2 / kernel 2.4.x.  Only with the newer
2.4.17/18 kernels though on the client-side.

I've now updated the autofs, hesiod and nfs-utils RPMs from Rawhide
(which may be required for newer kernel support???).  I'll let you if it
fixes my issues.  In the meantime, if anyone has any info, let me know.

-- Bryan

-- 
The USDOJ v. Microsoft trial will result in unconditional surrender.
No matter who wins, the consumer will be subject to the victor's
"terms."  Which is worse?  Clueless government or clueless monopoly?
--------------------------------------------------------------------
Bryan J. Smith, SmithConcepts, Inc.        mailto:b.j.smith@ieee.org
Engineers and IT Professionals          http://www.SmithConcepts.com



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
