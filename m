From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: Linux NFS FAQ updates
Date: Thu, 24 Apr 2003 08:44:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55565@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198itt-0003Cw-00
	for <nfs@lists.sourceforge.net>; Thu, 24 Apr 2003 08:44:41 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h3OFiZFB023646
	for <nfs@lists.sourceforge.net>; Thu, 24 Apr 2003 08:44:36 -0700 (PDT)
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.10.22.171])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h3OFiZJg007456
	for <nfs@lists.sourceforge.net>; Thu, 24 Apr 2003 08:44:35 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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

tom mcneal and i would like to announce a new
version of the Linux NFS FAQ that contains some
changes that you all should know about.

now that we've broken the questions into sections,
we've moved questions A2 through A4 to section B.
A2 through A4 have to do with the "async" export
option, and fit better in the performance section
than in the protocol section.  we will try to keep
question renumbering to a minimum, since these
questions now all have a name link associated with
them to enable folks to reference specific questions
in the FAQ, and we'd like those to remain stable
over time.

we've added a lot more detail to question A1, which
addresses the differences between the NFS Version 2
and Version 3 protocols.

finally, a new question B7 discusses a per-mount
performance limit in the Linux NFS client, and how
to work around it.


without announcement, a few weeks ago we added
several new questions.  question A5 addresses
Kerberos support in the Linux NFS implementation.
question A6 outlines the new features of the NFS
Version 4 protocol, while question A7 addresses
interoperability issues between NFS Versions
2/3 and NFS Version 4.

question A8 defines the term "close-to-open cache
consistency," and discusses when the Linux NFS client
began to support it.  and question B3 discusses the
"255 NFS mounts per client" limitation.

we invite you to visit the FAQ and send your comments
and suggestions.

        - Chuck Lever
--
corporate:   <cel at netapp dot com>
personal:    <chucklever at bigfoot dot com>


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
