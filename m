From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: status
Date: 18 Nov 2002 19:40:09 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptt2d8mu.fsf@charged.uio.no>
References: <F170m8eyLahVRaWhrkZ0001357e@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: "William Knop" <w_knop@hotmail.com>
In-Reply-To: <F170m8eyLahVRaWhrkZ0001357e@hotmail.com>
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

>>>>> " " == William Knop <w_knop@hotmail.com> writes:

     > Ah, doesn't NFSv3 not support concurrent reads? Or concurrent
     > reads while a file is open for writing or something like that? 

Something like that: it doesn't support calling back clients in order
to notify them of changes that occur on the server because the model
is designed to be stateless and thus to scale for large numbers of
clients.
Although NFSv4 adds the concept of state (and hence file locking) to
the protocol, it does not differ from NFSv3 in this respect.

You probably want to be looking at dedicated clustered filesystems
such as OpenGFS, for instance.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
