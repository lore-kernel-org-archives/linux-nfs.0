From: Mark Hemment <markhe@veritas.com>
Subject: Reply-cache
Date: Sat, 9 Aug 2003 15:25:44 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0308091522540.1062-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay-bridge.veritas.com ([143.127.3.10] helo=mtvmime03.VERITAS.COM)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19lUeS-0006il-00
	for <nfs@lists.sourceforge.net>; Sat, 09 Aug 2003 07:25:00 -0700
Received: from megami (unverified) by mtvmime03.VERITAS.COM
 (Content Technologies SMTPRS 4.2.10) with SMTP id <T63f2011a8a0a8911559e8@mtvmime03.VERITAS.COM> for <nfs@lists.sourceforge.net>;
 Sat, 9 Aug 2003 07:25:20 -0700
Received: from localhost.localdomain(markhe.wat.veritas.com[10.10.185.104]) (2577 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <markhe@veritas.com>)
	id <m19lUeM-00003jC@megami>
	for <nfs@lists.sourceforge.net>; Sat, 9 Aug 2003 07:24:54 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Received: from localhost (markhe@localhost)
	by localhost.localdomain (8.11.2/8.11.2) with ESMTP id h79EPi314262
	for <nfs@lists.sourceforge.net>; Sat, 9 Aug 2003 15:25:44 +0100
To: <nfs@lists.sourceforge.net>
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

  A few NFS reply-cache questions, and possible answers.  Any feedback
would be appreciated.

1) Is a reply-cache needed over a reliable transport (TCP)?
     Yes.  Possible for a client not to receive a response due to a
   disconnect.  When re-connects, will retry the operation.  Need to trap
   this.

2) Cache look-up before checking for a client's export entry?
     The reply-cache look-up/resource-allocation occurs from
   nfsd_dispatch() - before the exp_get() check in fh_verify().  This
   allows for an attacker to fill the reply-cache with 'bogus' entries,
   reducing it usefulness.  As NFS servers are either accessible only on
   an intranet, or behind a firewall (unlikely?), this is not a serious
   problem.
      Partial fix is in nfsd_cache_lookup(), after checking 'type', test
   if rq_client is NULL.   Not ideal, but will catch most cases.
      Full fix is to move call to nfsd_cache_lookup() into fh_verify()
   (and anywhere else needed(?)) after the exp_get_fsid()/exp_get().
      If this is consider an issue, shout and I'll do a patch.

3) For non-idempotent operations, hold an "inprogress-entry" in the
   reply-cache?
      This would really only be for read operations, and possibly getattr,
   over an unreliable transport (UDP).  On a 'busy' server, response
   times may vary considerably; by trapping retransmitted requests which
   are in-progress, the 'busy' server will not be further overloaded.
   Note: I have no data to back this case up!  Does anyone have some
   hard-data/references on this?
      Ideally, the 'inprogress' entry would be dropped _after_ the
   response has been sent.  With the current design, nfsd_dispatch() calls
   nfsd_cache_update() before returning to the RPC code for a call to
   svc_send().  A callback hook after svc_send() would be useful....

Thanks,
Mark



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
