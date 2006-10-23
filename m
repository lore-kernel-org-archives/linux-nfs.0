From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in hash
Date: Mon, 23 Oct 2006 15:51:53 -0400
Message-ID: <20061023195153.GA8983@fieldses.org>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gc5qH-0005E1-HR
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 12:52:13 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gc5qA-0000uo-Mi
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 12:52:14 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
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

On Wed, Oct 11, 2006 at 09:28:50PM +1000, Greg Banks wrote:
> knfsd: Use the client's IP address in the duplicate request cache
> hash function, instead of just the XID.

By the way, do we ever match the credential used on the replayed request
with the credential used on the original request?  From a quick check of
the code, I can't see any place where we do.

It strikes me as something as an attacker might be able to have some fun
with.  (Poison the cache with requests matching xid's you expect to be
used in the future?  "Replay" somebody else's request just to see a
response that you wouldn't otherwise have been able to?)

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
