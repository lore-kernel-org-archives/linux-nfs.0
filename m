From: Sven Geggus <sven@gegg.us>
Subject: Re: 2.4.21: NFS client Freeze
Date: Tue, 24 Jun 2003 21:01:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030624190113.GA2680@diesel.geggus.net>
References: <20030624101227.GA21744@benzin.geggus.net> <shsptl3tie2.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from benzin.geggus.net ([213.146.112.23] ident=foobar)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ut38-0002SM-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 12:01:51 -0700
Received: from diesel.geggus.net ([192.168.3.2])
	by benzin.geggus.net with esmtp
	(Exim 4.20 id 19Ut2X-0002Lm-NF)
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 21:01:13 +0200
Received: from sven by diesel.geggus.net with local
	(Exim 3.35 id 19Ut2X-0000i8-00)
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 21:01:13 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shsptl3tie2.fsf@charged.uio.no>
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

On Tue, Jun 24, 2003 at 08:55:33PM +0200, Trond Myklebust wrote:

> Nothing wrong there. Mind filling in the details?

what's wrong is the fact, that the machine is frozen after the

RPC:   26 call_decode (status 760) 

has been logged. As I already said, ping is still working, but nothing else.

Sven

-- 
begin  .signature
This signature is for serious Software only, there is no attachment!
end
/me is giggls@ircnet, http://sven.gegg.us/ on the Web



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
