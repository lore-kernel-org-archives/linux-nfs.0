From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: 05 Oct 2002 18:18:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6qovozl.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
	<shsy99ddayi.fsf@charged.uio.no>
	<1033793310.4626.0.camel@camp4.serpentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
	  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xrdE-0004Hy-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 09:18:20 -0700
To: Bryan O'Sullivan <bos@serpentine.com>
In-Reply-To: <1033793310.4626.0.camel@camp4.serpentine.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Bryan O'Sullivan <bos@serpentine.com> writes:

     > On Fri, 2002-10-04 at 16:46, Trond Myklebust wrote:
    >> Have you enabled CONFIG_HIGHMEM? If so, could you please try
    >> disabling it.

     > What's the issue with CONFIG_HIGHMEM, and on which machine
     > should it be expected to make a difference?

I'm seeing major slowdowns, mainly on NFS reads, when I enable
CONFIG_HIGHMEM. I haven't yet had time to investigate this.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
