From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: More about nfsd/lockd hang in 2.4.20+NFS_ALL
Date: Fri, 13 Jun 2003 09:31:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16105.64592.996167.136600@charged.uio.no>
References: <3EE9D5BB.6040600@geodev.com>
	<shsd6hikmgi.fsf@charged.uio.no>
	<3EE9F97C.9070006@geodev.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QrSS-0004Cn-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 09:31:20 -0700
To: Matthew Mitchell <matthew@geodev.com>
In-Reply-To: <3EE9F97C.9070006@geodev.com>
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

     > rpc.statd in this case is running as an unprivileged user, yes.
     > So lockd will not allow a local statd to talk to it unless it
     > is running on a privileged port?  That seems to be what is
     > going on in the conditional.  Next question is -- why?

For obvious reasons, you don't want any Tom, Dick or Harry to be able
to tell the kernel that it should try to recover locking state from a
given server.

     > Even assuming there is a good reason, why might it cause the
     > whole nfs system to hang?

My guess (since you are not supplying a tcpdump) is that the server is
down. That's when it is supposed to happen, anyway...

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
