From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Input/output error on hard mounted NFS directory
Date: 14 May 2002 14:52:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadr2gacv.fsf@charged.uio.no>
References: <Pine.LNX.4.30.0205141308300.28229-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177bnH-0006pw-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 05:52:43 -0700
To: Steffen Persvold <sp@scali.com>
In-Reply-To: <Pine.LNX.4.30.0205141308300.28229-100000@elin.scali.no>
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

>>>>> " " == Steffen Persvold <sp@scali.com> writes:

     > On 14 May 2002, Trond Myklebust wrote:
    >> >>>>> " " == Steffen Persvold <sp@scali.com> writes:
    >>
    >> > The error I get here is :
    >>
    >> > #     Creating static library Linux2.ia64.gnu/libmpi.a ...
    >> > #     Creating shared library Linux2.ia64.gnu/libmpi.so ...
    >> > /usr/bin/ld: final link failed: Stale NFS file handle
    >> > collect2: ld returned 1 exit status make[4]: ***
    >> > [Linux2.ia64.gnu/libmpi.a] Error 1
    >>
    >>
    >> Stale file handle has nothing to do with EIO. That looks more
    >> like a server bug. Are you perchance using nfs-server?

     > No, I'm using a standard RH 7.2 server with knfsd (and
     > nfs-utils-0.3.1-13.7.2.1). rpc.nfsd is started with 48 servers.

What is the filesystem you are using on the server? Would it be an old
ReiserFS 3.5 format disk? If so, you should consider upgrading it to a
3.6 format disk. See the manpage for 'mount -oconv' at www.namesys.com

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
