From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: RPC error on NFS over TCP
Date: Tue, 26 Mar 2002 09:27:31 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002d01c1d4da$c00d2310$2d060e09@beavis>
References: <200203260016.SAA38018@popmail.austin.ibm.com> <20020326071622.A28115@ead45>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Received: from mg01.austin.ibm.com ([192.35.232.18])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16psnT-0007iO-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 07:23:39 -0800
To: "Bill Rugolsky Jr." <brugolsky@yahoo.com>
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

> On Mon, Mar 25, 2002 at 06:05:03PM -0600, Andrew Theurer wrote:
> > The linux server is kernel 2.4.18 (with Neil's patches) and sometimes
2.5.7.
> > The clients (48 of them) are mostly just RH-2.4.2-2 and one is 2.5.7
(happens
> > on both kernels).  There are no dropped packets reported on ifconfig.
There
> > are RPC retransmits on the clients.  Any ideas?
>
> You may need more threads to service the clients?  See Neil's notes
> that accompanied the patches (in the archives) w.r.t the number of threads
> and the number of RPC receive buffers.


Thanks Bill!  I tried 128 threads and it seems to be OK so far.

-Andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
