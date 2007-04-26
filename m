From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: [PATCH] Stale NFS negative dentries caused by u32 jiffy
	wrap
Date: Thu, 26 Apr 2007 00:24:59 -0300
Message-ID: <20070426032459.GN10449@sleipnir.redhat.com>
References: <20070424162645.GD10449@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgubx-0001zG-9W
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 20:25:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hguby-0002eO-Ll
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 20:25:40 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3Q3PWxi029461
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 23:25:32 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3Q3PWlM028036
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 23:25:32 -0400
Received: from sleipnir.redhat.com (vpn-14-22.rdu.redhat.com [10.11.14.22])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3Q3PFRH029153
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 23:25:16 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l3Q3P6K5003799
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 00:25:07 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l3Q3P5aV003794
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 00:25:05 -0300
In-Reply-To: <20070424162645.GD10449@sleipnir.redhat.com>
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

On Tue, Apr 24, 2007 at 01:26:45PM -0300, Fabio Olive Leite wrote:
> =

> This patch solves an issue found on 32bit architectures, where jiffies
> wrap every 50 days. Since many NFS structures are very long lived and
> the code uses jiffies everywhere for timestamp comparisons, there are
> many places where old data can be considered newer than something
> fresh from the server. This one deals with negative dentries, and I'd
> like to have it discussed in the list for sanity checking.

Please disregard this email and patch. With extra testing, I found out
that time_after and friends are not suited at all to the type of
long-lived timestamp comparisons that the NFS code does. I'll start a
new thread for that.

Regards,
F=E1bio
-- =

ex sed lex awk yacc, e pluribus unix, amem

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
