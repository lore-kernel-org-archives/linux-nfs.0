From: David Myer <davidmyer800@yahoo.com>
Subject: Re: nfs client question -- kernel version 2.4.18
Date: Mon, 19 May 2003 20:17:00 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030520031700.35038.qmail@web21001.mail.yahoo.com>
References: <shsaddiqrve.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web21001.mail.yahoo.com ([216.136.227.55])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Hxca-0005U9-00
	for <nfs@lists.sourceforge.net>; Mon, 19 May 2003 20:17:00 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsaddiqrve.fsf@charged.uio.no>
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

Thanks for the reply.

I am not using skbuf underneath but have my own buffer
management and socket redirect stuff (can you believe
that ?), I am trying to avoid to do the copy stuff
here.

I am running both client and server in 2.4.18, do you
mean that the server side does NOT support tcp ? eh ?

Thanks again
David


--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:
> >>>>> " " == David Myer <davidmyer800@yahoo.com>
> writes:
> 
>      > Hi, I am trying to understand nfs client code
> in 2.4.18.  Would
>      > appreciate the following advise.
> 
>      > 1) in call_encode function (clnt.c), it
> initializes
>      > the iov base and len for send and recv, why
> it is only init
>      > iov[0] ? Does it mean it only use ONE IOV for
> data send and
>      > receive ?
> 
> The code shold be pretty clear there: half the
> buffer goes to the send
> iovec, the other half goes to the receive iovec.
> 
>      > If so, if I have use my own type of buffer
> underneath, can I
>      > just copy it into iov[0] ?
> 
> I suppose. Why would you do that though?
> 
>      > 2) In nfs2xdr.c's nfs_xdr_readdirres
> function, when
>      > nfs tries to get XDR data, it uses iov[1], I
> am not sure when
>      > the header and payload got splitted into
> iov[0] and iov[1]. I
>      > assume this happened ( in case of udp), in
> data copy in
>      > udp_data_ready, but I did not see this "split
> copy" happening.
> 
> That's what csum_partial_copy_to_page_cache() does.
> In
> nfs*_xdr_readdirargs(), we preallocate the RPC
> header (== iov[0]) so
> that the readdir data ends up in the page cache page
> iov[1].
> 
>      > 3) In command line, I am trying to mount
> using tcp by
>      > mount address1:/dir /address2:/mydir -o tcp
> it returned nfs
>      > server reported service unavailable: Protocol
> not available..
> 
>      > I saw on server side, when doing rpcinfo -p,
> mount daemon does
>      > have tcp, what else special I need to
> configure, on server or
>      > client side in order to mount using tcp ?
> 
> Err... An actual NFS daemon that supports TCP?
> 
> Cheers,
>   Trond

__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
