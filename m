From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: 10 May 2003 15:50:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbryauczr.fsf@charged.uio.no>
References: <3EBBA1FA.3090301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19EUkj-0005Ka-00
	for <nfs@lists.sourceforge.net>; Sat, 10 May 2003 06:51:05 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3EBBA1FA.3090301@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:

     > What this patch does is make the minimal Round Trip time value
     > relative to HZ. So When HZ is greater (as in the case of ia64)
     > the minimal value goes up.
     >  Comments?

1/30 of a second is a long time. Why that particular choice?

Note: "It works" won't cut ice as that is completely a function of the
choice of hardware.

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
