From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Problems with statd and lockd
Date: Sun, 6 Apr 2003 15:09:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200304061509.28615.bernd-schubert@web.de>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com> <200304051831.09682.bernd-schubert@web.de> <16016.6804.336490.539227@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp03.web.de ([217.72.192.158] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1929u3-0006iF-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Apr 2003 06:09:43 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <16016.6804.336490.539227@charged.uio.no>
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

>
> If secure-statd was the cause of the problem, I would expect
> additional messages of the form
>
>   "Call to statd from non-local host blah"
>
> or
>
>   "Attempt to register callback to 1000xy/z"
>
> or
>
>   "Attempt to register host blah (not a dotted quad)"

No, we have never seen anything like this.

>      > What problems can be caused by a statd without the secure
>      > option ?
>
> People could use your statd to make arbitrary RPC calls.
>

Hmm, though we are protected by a firewall on most ports, I better add a 
statd-line to /etc/hosts.allow  ;-)


Is there something I can do to debug this problem ?


Best regards,
	Bernd




-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
