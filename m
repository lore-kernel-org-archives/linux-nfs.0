From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fsid syntax
Date: 07 Aug 2002 17:26:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7n2d70y.fsf@charged.uio.no>
References: <200208071711.00712.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cShw-0004E4-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 08:26:44 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200208071711.00712.bernd-schubert@web.de>
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

>>>>> " " == Bernd Schubert <bernd-schubert@web.de> writes:

     > Hi, probably on Friday I need to make use of setting the fsid
     > in the /etc/exports.

     > Since I can't find the syntax in the exports manpage (manpage
     > was last time changed on Januar, while the fsid-feature seems
     > to be become added to cvs on February).

     > So I'd like to know the exact sytanx, is for example:

     > /testdir testnode(fsid=/dev/sdb)

The fsid is a number, not a device. In principle you can set it to any
number you like as long as you keep it consistent over reboots.

One suggestion is to use the device major/minor number in the format
minor + (major * 256). (That's what nfsd uses by default for block
devices.)

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
