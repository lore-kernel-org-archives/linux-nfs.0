From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: stale nfshandles in linux 2.2.17
Date: 20 Mar 2002 14:19:52 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshenbtlzb.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0203191708190.26134-100000@lgserv3.stud.cs.uit.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16ng0Z-0001xs-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 05:20:03 -0800
To: Audun Arnesen Nordal <audun@stud.cs.uit.no>
In-Reply-To: <Pine.LNX.4.44.0203191708190.26134-100000@lgserv3.stud.cs.uit.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Audun Arnesen Nordal <audun@stud.cs.uit.no> writes:

     > Please forgive me if this is not the proper place to post
     > questions like this.

     > I have a Raidzone Opennas box that came with a 2.2.17 kernel,
     > seemingly based on a redhat 6.1 or 6.2 distribution. The
     > filesystem I wish to export is ReiserFS 3.5.25. The host
     > contains special IDE-diskraid hardware and a kernel that came
     > with the box, thus I cannot easily recompile the sources.

I'd recommend an upgrade. 2.2.17 did not have good support for knfsd,
and it certainly would not have had all the extensions that were
needed in order to get ReiserFS & knfsd to talk to one another. (IIRC
fact the standard RH-2.2.17 kernel didn't even have support for
ReiserFS...)

Cheers,
   Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
