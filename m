From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: 29 Apr 2003 21:39:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssms1ozz6.fsf@charged.uio.no>
References: <3EAE956E.9080205@RedHat.com> <shs4r4h5l52.fsf@charged.uio.no>
	<3EAEC774.20402@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Aawc-0002fK-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 12:39:14 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3EAEC774.20402@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > Right... but with the difference being that statfs supplies
     > dynamic information and fsinfo supplies static info. And some

NFSPROC_STATFS supplies a bit of both. You have the dynamic 'blocks,
bfree, bavail', but you also have the static 'tsize' == r/wsize, and
'bsize'.

     > So I'm just curious, why (from a protocol purest standpoint)
     > its not being used... and if it ever was used, what were the
     > results...

I'm not sure I understand the question. In which case do you think we
should be using FSINFO/STATFS (but are currently not doing so)?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
