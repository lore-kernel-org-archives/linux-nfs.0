From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: 18 Sep 2003 01:52:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6dyabju.fsf@charged.uio.no>
References: <Pine.LNX.4.33.0309171251290.25153-100000@wombat.indigo.net.au>
	<3F689E40.6090802@intel.com> <3F68C6EB.2080706@zytor.com>
	<20030917210023.GA15099@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,  Arun Sharma <arun.sharma@intel.com>,
	  autofs@linux.kernel.org,  nfs@lists.sourceforge.net,
	  Ian Kent <raven@themaw.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zrjA-0002Bs-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 22:53:16 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zrj9-00059O-RC
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 22:53:16 -0700
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20030917210023.GA15099@suse.de>
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

>>>>> " " == Olaf Hering <olh@suse.de> writes:

     >  On Wed, Sep 17, H. Peter Anvin wrote:
    >> Okay... let me ask this so I get it straight...
    >>
    >> Has anyone seen this (busy inodes after stopping the
    >> automounter) using autofs v3 kernel module and daemon?

     > I'm not sure, but everyone who has seen this should fiddle this
     > patch into the kernel and see how it goes.  The whole thing
     > started very recently (post 2.4.21) for us.

     > This patch is untested, any feedback appreciated.

...and is indeed wrong... It does the exact opposite of what
sillydelete should do. Instead of causing the last application that
closes the file to perform the sillydelete, you are asking the *first*
application that closes it to do so.
Sillydelete *has* to be tied to dentries. Not files, and not
inodes. It is purely a namespace operation...

So exactly what are you trying to do, and why?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
