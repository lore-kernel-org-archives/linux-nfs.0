From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: NFSERR_EAGAIN
Date: Fri, 11 Jul 2003 10:55:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F0E8975.2000009@cinesite.co.uk>
References: <3F0DB088.303@cinesite.co.uk> <shsbrw20zue.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs <nfs@lists.sourceforge.net>, Iain Irwin-Powell <Iain@cinesite.co.uk>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19aucs-0006LN-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 02:55:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsbrw20zue.fsf@charged.uio.no>
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

Trond Myklebust wrote:

>>>>>>" " == Danny Smith <dannys@cinesite.co.uk> writes:
>>>>>>            
>>>>>>
>
>     > Looking through nfs2xdr.c and nfs.h and googling, it seems that
>     > error number 11 is not properly defined, but certainly seems to
>     > be in use by SGI. From nfs2xdr.c:
>
>     >      { NFSERR_NXIO, ENXIO },
>
>     > /* { NFSERR_EAGAIN, EAGAIN }, */
>     >       { NFSERR_ACCES, EACCES },
>
>     > (EAGAIN having value 11)
>
>     > Does anyone know much about the history of this? Was this
>     > removed in order to be RFC compliant, or is there a stronger
>     > motivation not to have this?
>
>Why should we be supporting something which isn't documented in the RFCs?
>
I really want to know how it got into the source in the first place? Is 
it a feature that's "not part of the standard, but seem to be widely 
used nevertheless" (quoting from nfs.h).

Searching around shows a (very) few ocurrences of this, with Solaris and 
IRIX servers, although often accompanied by other issues.

If the server is broken, but we can work with it anyway without 
upsetting anything else, this would be a "good thing" in my book (of 
course, we would take it up with SGI too).

>What is this error anyway? Is it some SGI hack for emulating
>NFS3ERR_JUKEBOX under NFSv2?
>  
>
Right now, I don't really know, but I'm guessing it's something of the 
sort (seems to make sense with what we're seeing).
I'm trying to get a packet trace to verify this is indeed what is being 
sent - will update when I have further evidence.

Danny

-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
