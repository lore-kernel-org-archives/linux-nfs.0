From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Vaguely NFS related problem
Date: 13 Dec 2002 15:07:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65ty9fn5.fsf@charged.uio.no>
References: <3DF7EA94.20108@atheros.com>
	<15863.61586.150820.505519@notabene.cse.unsw.edu.au>
	<3DF7F663.30201@atheros.com>
	<15863.64480.756681.957850@notabene.cse.unsw.edu.au>
	<3DF8C2BF.8050109@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MqTI-0007f8-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 06:07:20 -0800
To: "Jeff L. Smith" <jeff@atheros.com>
In-Reply-To: <3DF8C2BF.8050109@atheros.com>
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

>>>>> " " == Jeff L Smith <jeff@atheros.com> writes:

     > I plan to upgrade to 2.4.20 as soon as I can take the
     > fileservers down long enough, but that will be a few weeks.
     > But then that begs the question, should I apply Trond's 2.4.20
     > patches?

FYI: There are no further NFS server-related patches in my 2.4.20
patchsets.

The only server patches I included earlier were beta-versions of the
NFS over TCP related stuff ('cos they conflicted with some of the
client changes). Now that the finalized TCP code has been merged into
the mainstream kernel by Neil, I've dropped them.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
