From: Per Olofsson <pelle@dsv.su.se>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 23:54:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830215448.GO3671@nasse>
References: <20040824184138.GB3251@nasse> <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org> <20040830020132.GA28919@fieldses.org> <20040830154541.GA3671@nasse> <1093884302.8729.21.camel@lade.trondhjem.org> <20040830171734.GC1555@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Paul Jakma <paul@clubi.ie>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1u7C-0000DW-CG
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 14:55:02 -0700
Received: from nl-ams-slo-l4-01-pip-3.chellonetwork.com ([213.46.243.17] helo=amsfep12-int.chello.nl)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C1u7B-0004ox-Ma
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 14:55:02 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040830171734.GC1555@fieldses.org>
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

J. Bruce Fields:
> I think that adding rpcsec_gss support to the userland utilities, and
> making it easy for people to distribute keytabs to their clients, is the
> better long-term solution than enabling RFC2623's workarounds.  But
> maybe too many clients already expect to be able to mount with auth_sys
> only.

I think there are some benefits with allowing mounting without
requiring a keytab. For example, I'd like to give my users the ability
to mount their home directories from outside of the department
(e.g. their home computers). I don't think it would be practical to
distribute keytabs to all of them, and in many cases it simply doesn't
work (dynamic IPs, NAT, etc.).

It would also be nice to be able to fallback to something similar to
auth_sys with all_squash in case there's no ticket/keytab present for
the current user. This is roughly how AFS behaves. It's not too
important, though.

-- 
Pelle


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
