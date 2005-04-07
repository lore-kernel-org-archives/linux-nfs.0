From: Neil Horman <nhorman@redhat.com>
Subject: Re: NFS experince story, questions.
Date: Thu, 7 Apr 2005 16:09:39 -0400
Message-ID: <20050407200939.GB3102@hmsendeavour.rdu.redhat.com>
References: <1112894081.6230.9.camel@vasiliy.coinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJdJu-0006lA-Ce
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 13:09:42 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DJdJs-0005i2-OC
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 13:09:42 -0700
To: Vasiliy Boulytchev <vasiliy@lohankin.com>
In-Reply-To: <1112894081.6230.9.camel@vasiliy.coinfotech.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Apr 07, 2005 at 11:14:41AM -0600, Vasiliy Boulytchev wrote:
> 
> Ladies and Gents,
> 	In my previous experience, I have never had good luck with NFS.  We
> used NFS to balance mail server queues (for spam and virus filtering)
> between scanning nodes, and we ran into tons of problems, probably due
> to lack of complete understanding and proper configuration on my part.
> The performance was great, however, we kept getting stale mounts, and to
> get things back, both sides needed to be rebooted, I could not just
> unmount.  Maybe we were not mounting properly, but who knows.  Anyways,
> as an alternative we looked into samba, and that solved all our issues.
> We still run samba as the networking protocol, and are happy with it.
> 
> 	A new task has come up, and we are looking back at NFS, since samba
> really does not allow us to have proper user arrangements.  I really am
> afraid of having stale mounts again.  Is this a common newbie problem,
> or is this the nature of NFS?  When either of the nodes becomes
> unstable, has to reboot, (or a failover occurs), does this mean the
> other node will have a stale mount point and will need a reboot?
> 
When you say "stale mounts" do you mean file access operations are returning a
"Stale File handle" error?

Regards
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
