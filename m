From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: EJUKEBOX and Java
Date: Tue, 02 Apr 2002 18:38:51 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAA4F1B.1050803@emageon.com>
References: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B9008@perm01.woodside.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from tisch.mail.mindspring.net ([207.69.200.157])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16sYqr-000802-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Apr 2002 16:42:13 -0800
To: "Kent, Ian I." <Ian.Kent@woodside.com.au>
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

Understood, but when the EJUKEBOX error is encountered by our 
application, the fact that RPC blocks signals (via rpc_clnt_sigmask) 
during this sleep seems to cause every thread in the Java VM to 
"deadlock" (we can even see the garbage collector stop) until data 
starts to stream back from the NFS server. This is our current working 
theory anyway.


Kent, Ian I. wrote:

>The NFSv3 RFC specifies the client behaviour you are seeing for this server return.
>
>It's not a deadlock, the client sleeps, then retries.
>



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
