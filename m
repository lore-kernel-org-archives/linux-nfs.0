From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Wed, 17 Sep 2003 09:46:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16232.26027.789453.979782@charged.uio.no>
References: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com>
	<3EC39FDF.60609@RedHat.com>
	<16067.42148.524146.39488@charged.uio.no>
	<20030917041418.GA8900@outblaze.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
    "Lever, Charles" <Charles.Lever@netapp.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zcdd-0001zz-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 06:46:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zcdd-000679-3a
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 06:46:33 -0700
To: Yusuf Goolamabbas <yusufg@outblaze.com>
In-Reply-To: <20030917041418.GA8900@outblaze.com>
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

>>>>> " " == Yusuf Goolamabbas <yusufg@outblaze.com> writes:

     > Trond, In your opinion. What should be the default retrans
     > value given your recent work in having adaptive timeouts in the
     > NFS client ?

I'd like to cap the minimum value for the estimated error on the RTO
at 1/10sec as per the 2.6 kernel (currently it is set at 2/HZ sec ~
2/100sec on most architectures, but 2/1000sec on ia64).

Then I'd like to increase the default value that "mount" uses for
"retrans" to the kernel value (which is currently set at 5).

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
