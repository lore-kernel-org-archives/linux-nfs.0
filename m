From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 in nfs-server 2.2beta47?
Date: 26 Jun 2002 17:07:53 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs4rfqkrhy.fsf@charged.uio.no>
References: <200206260128.g5Q1SIL13005@mail19.bigmailbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NEPs-00024b-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 08:09:08 -0700
To: "Peter Plantagenet" <plantagenet@music.com>
In-Reply-To: <200206260128.g5Q1SIL13005@mail19.bigmailbox.com>
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

>>>>> " " == Peter Plantagenet <plantagenet@music.com> writes:

     > I would like to avoid building a new kernel on this machine if
     > possible, and find it hard to believe that the user-space nfs
     > really only provides v2.

Believe it. The userspace thing is unmaintained legacy software and is
in any case too fundamentally borken for anybody to seriously consider
adding v3 support...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabberConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
