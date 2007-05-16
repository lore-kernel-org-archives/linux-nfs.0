From: Baurzhan Ismagulov <ibr@radix50.net>
Subject: Re: flock LOCK_EX hangs
Date: Thu, 17 May 2007 00:09:05 +0200
Message-ID: <20070516220905.GA7480@radix50.net>
References: <20070516131253.GC19167@radix50.net>
	<20070516173008.GD9895@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoRgb-00088R-2z
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 15:09:33 -0700
Received: from kz-easy.com ([85.214.25.173] helo=almaty.kz-easy.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoRgc-00042E-2t
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 15:09:36 -0700
Received: from alatau.radix50.net (dslb-088-064-026-025.pools.arcor-ip.net
	[88.64.26.25]) (authenticated bits=0)
	by almaty.kz-easy.com (8.13.8/8.13.8/Debian-3) with ESMTP id
	l4GM9E0D011317
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Thu, 17 May 2007 00:09:21 +0200
Received: from alatau.radix50.net (localhost [127.0.0.1])
	by alatau.radix50.net (8.13.8/8.13.8/Debian-3) with ESMTP id
	l4GM987e008374
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Thu, 17 May 2007 00:09:08 +0200
Received: (from ibr@localhost)
	by alatau.radix50.net (8.13.8/8.13.8/Submit) id l4GM95Uf008373
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:09:05 +0200
In-Reply-To: <20070516173008.GD9895@fieldses.org>
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


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Bruce,

On Wed, May 16, 2007 at 01:30:08PM -0400, J. Bruce Fields wrote:
> Might be fun to watch the network traffic as this is happening.

Eh, I've hoped someone would have a silver bullet for me, so that I
don't have to do that :) .

There is one LOCK request and one LOCK reply with the NLM DENIED GRACE
PERIOD error. Does this say anything?

This is still under 2.6.16, I'm planning to upgrade on Friday, unless
the problem can be solved with the current version. Besides, is it
possible to turn on logging? Also, I've seen the following messages in
the kernel log: "do_vfs_lock: VFS is out of sync with lock manager!"
This happened only when I dumped the traffic the last time, not within
the day, when I tried many times (the logs were not rotated).

Any ideas?

With kind regards,
-- 
Baurzhan Ismagulov
http://www.kz-easy.com/

--82I3+IH0IqGh5yIs
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="flock01.tcpdump.gz"
Content-Transfer-Encoding: base64

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
PwAA

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--82I3+IH0IqGh5yIs--
