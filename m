From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Bug: 2.5.47 NFS reports giant filename in readdir
Date: Tue, 19 Nov 2002 19:28:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15834.33491.457499.318002@charged.uio.no>
References: <20021119173951.1270.qmail@linuxmail.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ED77-0003Ae-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 10:28:45 -0800
To: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
In-Reply-To: <20021119173951.1270.qmail@linuxmail.org>
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

>>>>> " " == Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> writes:

     > I applied the patch to 2.4.20-rc2 but it isn't still working
     > 100%.  Now, when I do an "ls" over the same NFS-mounted
     > directory, I do only get a partial list of files (~500 files of
     > 17000)... "dmesg" on 2.4.20-rc2 reveals the following message:

     >    NFS: readdir reply truncated!

     > Any more ideas? :-)

Then I'll need more details on your setup. Server type, mount
options,..., and possibly the raw tcpdump output of the last few NFS
calls just before you get the 'readdir reply truncated'
message. Please remember to use a large value for the snaplen
(e.g. '-s 8192')

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
