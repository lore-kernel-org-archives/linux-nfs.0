From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Null characters in files on NFS mounted volume....
Date: 13 May 2002 17:08:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuu8ytk4.fsf@charged.uio.no>
References: <3CDFCE9F.2BE050D5@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177HQy-0005Ik-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 08:08:21 -0700
To: Dan Yocum <yocum@fnal.gov>
In-Reply-To: <3CDFCE9F.2BE050D5@fnal.gov>
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

>>>>> " " == Dan Yocum <yocum@fnal.gov> writes:

     > Hi all, I've got a "New and Exciting" <tm> bug using 2.4.18
     > with Trond's client patches (sans the rpc_tweaks dif), but I'm
     > not sure it's a client side problem.

     > This is an intermitent problem: When attempting to read a file
     > (any file) on an NFS mounted volume, there appear to be "holes"
     > in the file filled with ASCII NULL characters.  Reading the
     > file on the local machines shows no such holes, and other NFS
     > clients don't see the holes, either.  A simple umount/remount
     > solves the problem.

Any details?

Are these for instance ordinary files? Are you perhaps engaging in
some multiple NFS client read/writes to the same file? ...  Is it tied
to the client patches, or does it occur with stock 2.4.18 fresh off
the l-k presses?

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
