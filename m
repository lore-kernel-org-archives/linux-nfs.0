From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: More about nfsd/lockd hang in 2.4.20+NFS_ALL
Date: 13 Jun 2003 14:21:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7bpy8q2.fsf@charged.uio.no>
References: <3EE9D5BB.6040600@geodev.com> <shsd6hikmgi.fsf@charged.uio.no>
	<3EE9F97C.9070006@geodev.com>
	<16105.64592.996167.136600@charged.uio.no>
	<3EEA006C.2080203@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QvzK-0001ZT-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 14:21:34 -0700
To: Matthew Mitchell <matthew@geodev.com>
In-Reply-To: <3EEA006C.2080203@geodev.com>
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

>>>>> " " == Matthew Mitchell <matthew@geodev.com> writes:

     > According to rpcinfo on this server, which is also the client,
     > port 32769 is "sgi_fam".  What is that?  status is 32768.
     > Perhaps it's rejecting it with good cause.

fam has nothing to do with NFS. It is a 'file alteration
monitor'. ('man fam')

     > Hmm.  So the messages from lockd could just be a symptom of the
     > problem (nfsd locking up), you think.  I first noticed the
     > problem when a remote user logged into the server, and the home
     > directory (exported by the server) got remounted by the
     > automounter on a local path.

If you think that fam is screwing with NFS then kill it. It is hardly
a critical service on most setups.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
