From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs stalls on cp with certain file sizes with jumbo-gigabit
Date: 28 Dec 2003 16:21:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shszndcabau.fsf@susy.uio.no>
References: <3FEF4206.7070300@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AaiLk-0005yC-8T
	for nfs@lists.sourceforge.net; Sun, 28 Dec 2003 13:21:24 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AaiLj-0002Th-AO
	for nfs@lists.sourceforge.net; Sun, 28 Dec 2003 13:21:23 -0800
To: "Martin L. Purschke" <purschke@bnl.gov>
In-Reply-To: <3FEF4206.7070300@bnl.gov>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Martin L Purschke <purschke@bnl.gov> writes:

     > Hello,

     > I have a few linux nfs servers, all identical, dual gigabit
     > NIC's, one on mtu 1500 and one on another jumbo-frame
     > network. I have dozens of nfs clients on the regular network
     > and never had a problem. I recently started to move machines to
     > the jumbo-frame network. I came across a strange problem that a
     > nfs client stalls when cp'ing a file with a certain file
     > size. (There are many other ways to get the nfs client to stall
     > that has so far prevented me from deploying machines on the
     > J-network, but this one is easily reproducible).

This is not an NFS problem. It sounds rather as if jumbo frames is
poorly supported for your hardware/driver combination (a common
problem).

You'll have better luck reporting it to the networking mailing lists.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
