From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat Linux 2.4.9-31 and Solaris 5.7 with Apache
Date: 04 Apr 2002 12:38:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shspu1f695j.fsf@charged.uio.no>
References: <3CAB18EE.4000809@arm.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
To: Ron Reed <ron.reed@arm.gov>
In-Reply-To: <3CAB18EE.4000809@arm.gov>
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

>>>>> " " == Ron Reed <ron.reed@arm.gov> writes:

     > I have run into a strange problem that is causing me some
     > headaches. I have done some searches for an answer, we have
     > even talked with RedHat support with no solution. I am hopeing
     > that someone on the list can help me solve this. Here is the
     > setup, a Redhat 7.1, kernel 2.4.9-31, with the latest nfs-utils
     > release has a 140 gig raid array attached to it.  This is our
     > NFS server. One of the clients is a Sun Solaris 5.7 machine.
     > Everything seems to work just fine, until something happens to
     > the Apache 1.3.19 daemon running on the Solaris over a NFS
     > mount. Here is the oops output that has been run thru ksymoops:

Despite RedHat's dogged insistence that Linux 2.4.9 should be alright
for most users needs, a lot of water has been passed since then (you
will find several lockd updates in the Changelogs on
ftp.kernel.org). I would therefore recommend that you first try to
reproduce the problem with a newer kernel.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
