From: George Garvey <tmwg-nfs@inxservices.com>
Subject: Re: NFS Performance with sync or async
Date: Tue, 31 May 2005 09:54:19 -0700
Message-ID: <20050531165419.GC20637@inxservices.com>
References: <482A3FA0050D21419C269D13989C611308539BBA@lavender-fe.eng.netapp.com> <20050528125343.GY4944@inxservices.com> <1117313519.10746.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdA0q-0002If-8C
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 09:54:44 -0700
Received: from [63.193.79.19] (helo=mwg.inxservices.lan)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DdA0n-00028f-SQ
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 09:54:44 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1117313519.10746.20.camel@lade.trondhjem.org>
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

On Sat, May 28, 2005 at 01:51:59PM -0700, Trond Myklebust wrote:
> Note that there are two "sync" options: one affects the server behaviour
> causing it to always make sure that the data reaches the disk if/when
> the client requests it (see 'man 5 exports') and the other affects the
> client (and is a mount option).

   Thanks. I'm an idiot. I need to recheck everything based on this
misunderstanding. I may have made some other mistakes.
   I believed I saw some people talking about changing the mount
default to sync from async. That may be bad memory, but helped my
misconception ;)


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
