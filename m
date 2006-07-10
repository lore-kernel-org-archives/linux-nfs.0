From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 10:07:43 +0200
Message-ID: <200607101007.43824.agruen@suse.de>
References: <C98692FD98048C41885E0B0FACD9DFB8028CEAAC@exnane01.hq.netapp.com>
Reply-To: nfsv4@ietf.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@sun.com>, Sam Falkner <Sam.Falkner@sun.com>,
	nfs@lists.sourceforge.net, "Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fzqqd-0006JR-4U
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 01:10:31 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fzqqc-00059k-FI
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 01:10:31 -0700
To: nfsv4@ietf.org
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB8028CEAAC@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Saturday, 8. July 2006 17:04, Noveck, Dave wrote:
> Andreas has asked that we consider his proposal when disucssing
> where to go with regard to ACL in v4.1, at the Montreal IETF
> meeting.
>
> I'm wondering whether we should be discussing specific mechanisms.

IMO this depends on the time you want to allocate for it. The topic is 
nontrivial, so discussing the various aspects will probably take an hour or 
more, depending on how many basic POSIX concepts need to be revisited.

> It would help me if we could have a discussion of what the goals
> should be for ACL's in v4.1.  This isn't resally clear to me but
> it could be due to my lack of attention to the matter.

NFSv4 ACLs have known weaknesses in POSIX environments which implement ACLs in 
one form or another (be it the POSIX draft ACLs or NFSv4 ACLs). Both kinds of 
ACLs can be implemented in a way so that they are POSIX compliant. Generic 
NFSv4 ACLs are not POSIX compliant by themselves though. My goals for NFSv4.1 
ACLs would be to:

 - define mechanisms which can be used to achieve *full* POSIX compliance of
   NFSv4.1 ACLs, on systems which implement a POSIX compliant ACL model,

 - ensure that the mechanisms are general enough to not restrict the NFSv4
   ACL model more than absolutely necessary,

 - ensure that both POSIX-to-POSIX and Windows-to-Windows system interaction
   will be as flawless as can be,

 - ensure that POSIX-to-Windows and Windows-to-POSIX system interaction will
   be as flawless as can be,

 - design the mechanisms is a way so that they have as few artefacts as can
   be, and finally,

 - NFSv4.1 ACLs should not limit our possible future design options more than
   absolutely necessary. In particular, they should not preclude alternative
   solutions which achieve the same goals.

Thanks,
Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
