From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: frontpage sucks
Date: 22 Aug 2002 01:34:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8z2zg51t.fsf@charged.uio.no>
References: <200208211549.g7LFnSkV023067@iohost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hezW-0006aa-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 16:34:22 -0700
To: nfs@septuagint.org
In-Reply-To: <200208211549.g7LFnSkV023067@iohost.com>
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

>>>>> " " == nfs  <nfs@septuagint.org> writes:

     > I have *SEARCHED* and *SEARCHED* the net and can't find
     > anything that touches on my problem.

How about checking the NFS list archives?

     > Aug 20 20:29:00 w2a kernel: lockd: cannot monitor xx.xx.xx.xx
     > Aug 20 20:29:00 w2a kernel: lockd: failed to monitor

You are not running rpc.statd. It has to be running on the server
*and* the client.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
