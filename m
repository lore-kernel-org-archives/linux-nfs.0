From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Null characters in files on NFS mounted volume....
Date: Tue, 14 May 2002 06:29:34 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15584.8750.59660.285982@notabene.cse.unsw.edu.au>
References: <3CDFCE9F.2BE050D5@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177MSI-0001uz-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 13:30:02 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <yocum@fnal.gov>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Tue, 14 May 2002 06:29:53 +1000
To: Dan Yocum <yocum@fnal.gov>
In-Reply-To: message from Dan Yocum on Monday May 13
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

On Monday May 13, yocum@fnal.gov wrote:
> Hi all,
> 
> I've got a "New and Exciting" <tm> bug using 2.4.18 with Trond's client
> patches (sans the rpc_tweaks dif), but I'm not sure it's a client side
> problem.
> 
> This is an intermitent problem:  When attempting to read a file (any file)
> on an NFS mounted volume, there appear to be "holes" in the file filled with
> ASCII NULL characters.  Reading the file on the local machines shows no such
> holes, and other NFS clients don't see the holes, either.  A simple
> umount/remount solves the problem.

I remembers long ago some referred to NFS as
   Nulls Frequently Substituted
because they were experiencing exactly this sort of thing, and it
wasn't on Linux at all.

You wouldn't be using 'soft' mounts would you?

NeilBrown

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
