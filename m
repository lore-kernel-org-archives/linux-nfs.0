From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: EJUKEBOX and Java
Date: Wed, 3 Apr 2002 13:39:42 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CE34@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, "Kent, Ian I." <Ian.Kent@woodside.com.au>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16ssU8-0007aZ-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Apr 2002 13:40:04 -0800
To: "'Brian Tinsley'" <btinsley@emageon.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

this could appear because your Java threads are emulated
entirely in user space (green threads?).  if one of the
threads goes into the kernel via a system call and doesn't
return, then your entire JVM is hung.

just a thought.

> -----Original Message-----
> From: Brian Tinsley [mailto:btinsley@emageon.com]
> Sent: Tuesday, April 02, 2002 7:39 PM
> To: Kent, Ian I.
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] EJUKEBOX and Java
> 
> 
> Understood, but when the EJUKEBOX error is encountered by our 
> application, the fact that RPC blocks signals (via rpc_clnt_sigmask) 
> during this sleep seems to cause every thread in the Java VM to 
> "deadlock" (we can even see the garbage collector stop) until data 
> starts to stream back from the NFS server. This is our 
> current working 
> theory anyway.
> 
> 
> Kent, Ian I. wrote:
> 
> >The NFSv3 RFC specifies the client behaviour you are seeing 
> for this server return.
> >
> >It's not a deadlock, the client sleeps, then retries.
> >
> 
> 
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
