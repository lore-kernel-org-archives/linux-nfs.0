From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS inconsistent behaviour
Date: Wed, 18 Oct 2006 14:37:12 -0400
Message-ID: <1161196632.6095.94.camel@lade.trondhjem.org>
References: <A93BD15112CD05479B1CD204F7F1D4730513DB@exch-04.noida.hcltech.com>
	<46465bb30610160013v47524589g39c61465b5955f65@mail.gmail.com>
	<20061016084656.GA13292@janus>
	<46465bb30610160235m211910b6g2eb074aa23060aa9@mail.gmail.com>
	<20061016093904.GA13866@janus>
	<46465bb30610171822h3f747069ge9a170f1759af645@mail.gmail.com>
	<20061018063945.GA5917@janus>
	<1161194229.6095.81.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Mohit Katiyar <katiyar.mohit@gmail.com>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaGII-000148-Cr
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:37:34 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaGIG-0001ki-Cp
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:37:35 -0700
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <1161194229.6095.81.camel@lade.trondhjem.org>
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

On Wed, 2006-10-18 at 13:57 -0400, Trond Myklebust wrote:
> Note also that you _can_ change the range of ports used by the NFS
> client itself at least. Just edit /proc/sys/sunrpc/{min,max}_resvport.
> On the server side, you can use the 'insecure' option in order to allow
> mounts that originate from non-privileged ports (i.e. port > 1024).
> If you are using strong authentication (for instance RPCSEC_GSS/krb5)
> then that actually makes a lot of sense, since the only reason for the
> privileged port requirement was to disallow unprivileged NFS clients.

Oops... Something got lost there. That last sentence should read

        ...since the only reason for the privileged port requirement was
        to disallow unprivileged NFS clients that could be used to spoof
        other user identities via the weak AUTH_SYS authentication.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
