From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Questions about NFS over TCP
Date: Wed, 23 Apr 2003 17:44:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16038.46298.261383.948440@charged.uio.no>
References: <3EA66B58.2B1E4A45@moving-picture.com>
	<shsznmhtn7m.fsf@charged.uio.no>
	<3EA6A7AE.4F5200E7@moving-picture.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198MQB-0002W5-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 08:44:32 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3EA6A7AE.4F5200E7@moving-picture.com>
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

>>>>> " " == James Pearson <james-p@moving-picture.com> writes:

     > Thanks for the info - do you know what the 'best' combination
     > of (2.4.X) kernel/patches gives the most stable NFS over TCP
     > support?

As far as the client is concerned, 2.4.21-rc1 on its own should
suffice. I have no outstanding NFS over TCP patches beyond what I've
already fed to Linus and Marcelo.

Neil might have some further server side fixes though. I suggest that
you check his website.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
