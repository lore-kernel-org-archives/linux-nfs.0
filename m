From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how to test rpc_pipefs
Date: Fri, 06 May 2005 16:09:31 -0400
Message-ID: <1115410171.1960.26.camel@lade.trondhjem.org>
References: <20050506161018.GA3979@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DU98o-0007uo-Pb
	for nfs@lists.sourceforge.net; Fri, 06 May 2005 13:09:42 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DU98n-00073z-1Q
	for nfs@lists.sourceforge.net; Fri, 06 May 2005 13:09:42 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050506161018.GA3979@infradead.org>
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

fr den 06.05.2005 Klokka 17:10 (+0100) skreiv Christoph Hellwig:
> I have some simple changes to make rpc_pipefs use less obscure VFS
> APIs and I'd like to test it before submitting, any idea how to give
> rpc_pipefs some coverage without settign up a full-blown NFSv4 env?

Hi Christoph,

Well, all NFS environments (including v2 and v3) automatically create a
basic set of files in the nfs/clnt* subdirectory, but beware of
generalising that file behaviour since the open(), read(), write() and
close() are directly hooked by the objects you are exporting (krb5, and
idmap).

Could you be a bit more specific about what kind of API changes you are
proposing?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
