From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: 18 Sep 2003 08:13:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsoexi1egp.fsf@charged.uio.no>
References: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com>
	<3EC39FDF.60609@RedHat.com> <16067.42148.524146.39488@charged.uio.no>
	<20030917041418.GA8900@outblaze.com>
	<16232.26027.789453.979782@charged.uio.no>
	<20030918070352.GA23924@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zxfr-0001En-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 05:14:15 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zxfl-0002w6-8R
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 05:14:09 -0700
To: Yusuf Goolamabbas <yusufg@outblaze.com>
In-Reply-To: <20030918070352.GA23924@outblaze.com>
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

    >> Then I'd like to increase the default value that "mount" uses
    >> for "retrans" to the kernel value (which is currently set at
    >> 5).

     > What value are you looking at ?

The point is that we need statistics from those people who are seeing
problems. On my own setups, "5" is quite sufficient to eliminate all
the false positives. With the cap of timeo at 1/10sec, that
corresponds to a minimum "soft" timeout value after 6.3 seconds.

I've already asked once on these lists whether or not that suffices
for other people too, and have received no reply.

Without adequate statistics, I see no reason to change the existing
default...

     > Also man 5 nfs seems (in RH 9) that default retrans value is 3

The manpage needs to be changed too but not before 'mount' is.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
