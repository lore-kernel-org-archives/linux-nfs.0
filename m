From: "William Knop" <w_knop@hotmail.com>
Subject: Re: Re: status
Date: Mon, 18 Nov 2002 18:24:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F138Mwr9y4cp51dyZSd000147f4@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: trond.myklebust@fys.uio.no
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

I'd like to use OpenGFS, but from what I've heard it's very not useable. If 
someone would tell me otherwise, I'd be happy to give it a shot.


>From: Trond Myklebust <trond.myklebust@fys.uio.no>
>To: "William Knop" <w_knop@hotmail.com>
>CC: NFS@lists.sourceforge.net
>Subject: Re: [NFS] Re: status
>Date: 18 Nov 2002 19:40:09 +0100
>MIME-Version: 1.0
>Received: from mons.uio.no ([129.240.130.14]) by mc6-f6.law1.hotmail.com 
>with Microsoft SMTPSVC(5.0.2195.5600); Mon, 18 Nov 2002 10:40:12 -0800
>Received: from charged.uio.no ([129.240.86.49])by mons.uio.no with esmtp 
>(Exim 2.12 #7)id 18Dqoc-0007XR-00; Mon, 18 Nov 2002 19:40:10 +0100
>Received: from trondmy by charged.uio.no with local (Exim 2.12 #1)id 
>18Dqob-00069i-00; Mon, 18 Nov 2002 19:40:09 +0100
>References: <F170m8eyLahVRaWhrkZ0001357e@hotmail.com>
>In-Reply-To: <F170m8eyLahVRaWhrkZ0001357e@hotmail.com>
>Message-ID: <shsptt2d8mu.fsf@charged.uio.no>
>Lines: 17
>User-Agent: Gnus/5.0808 (Gnus v5.8.8) XEmacs/21.4 (Common Lisp)
>Sender: Trond Myklebust <trond.myklebust@fys.uio.no>
>Return-Path: trondmy@charged.uio.no
>X-OriginalArrivalTime: 18 Nov 2002 18:40:13.0155 (UTC) 
>FILETIME=[EE27CB30:01C28F31]
>
> >>>>> " " == William Knop <w_knop@hotmail.com> writes:
>
>      > Ah, doesn't NFSv3 not support concurrent reads? Or concurrent
>      > reads while a file is open for writing or something like that?
>
>Something like that: it doesn't support calling back clients in order
>to notify them of changes that occur on the server because the model
>is designed to be stateless and thus to scale for large numbers of
>clients.
>Although NFSv4 adds the concept of state (and hence file locking) to
>the protocol, it does not differ from NFSv3 in this respect.
>
>You probably want to be looking at dedicated clustered filesystems
>such as OpenGFS, for instance.
>
>Cheers,
>   Trond


_________________________________________________________________
STOP MORE SPAM with the new MSN 8 and get 2 months FREE* 
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
