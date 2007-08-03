From: Neil Brown <neilb@suse.de>
Subject: Re: NFS Caching / Locking
Date: Sat, 4 Aug 2007 09:19:36 +1000
Message-ID: <18099.47112.453973.722567@notabene.brown>
References: <F31FEAB987B7C2469181758C14265CFA040BBABB@gvlexch03.is.l-3com.com>
	<18098.54654.108131.864508@notabene.brown>
	<F31FEAB987B7C2469181758C14265CFA040BBABD@gvlexch03.is.l-3com.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Mock, JV Jason @ IS" <Jason.V.Mock@L-3Com.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH6Qv-000697-4n
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 16:19:50 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IH6Qw-00048Y-NG
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 16:19:53 -0700
In-Reply-To: message from Mock, JV Jason @ IS on Friday August 3
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday August 3, Jason.V.Mock@L-3Com.com wrote:
> 
> Either way, this mechanism works with the 2.6.9-32 RHEL4 kernel, however
> when updating to the 2.6.22.1 within RHEL4 it does not.  For example if
> I lock on COMPUTER1, and then check the lock in a separate process on
> COMPUTER1 I get F_WRLCK.  If I lock on COMPUTER1 and the check the lock
> on COMPUTER2, I get F_UNLCK.

Odd.  I just tried the same experiment with 2.6.22 clients and it
worked perfectly.
On one client:

  open("testlocking", O_RDWR)             = 3
  fcntl64(3, F_SETLKW, {type=F_WRLCK, whence=SEEK_CUR, start=0, len=0}) = 0

On the other
  open("testlocking", O_RDONLY)           = 3
  fcntl(3, F_GETLK, {type=F_WRLCK, whence=SEEK_SET, start=0, len=1, pid=0}) = 0


Can you 
 1/ report full mount options as passed to 'mount' and as reported
    by /proc/mounts.
 2/ get an 'strace' of the locking code, as above.
 3/ get a tcpdump of nfsd and lockd traffic between server and both
     clients
       (tcpdump -w /tmp/file -s0 port 2049 or port WHATEVER-LOCKD-IS-USING)

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
